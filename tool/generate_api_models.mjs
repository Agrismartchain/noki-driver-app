#!/usr/bin/env node
// Deterministic Dart model generator for the NOKI Driver App.
//
// Source of truth: the canonical OpenAPI document published through
// noki-shared-contracts (../noki-shared-contracts/spec/openapi/noki-api.openapi.json).
// This script does NOT talk to noki-api or noki-shared-contracts directly beyond
// reading that one checked-in file, and refuses to run if its checksum does not
// match contract/lock.json - the mobile contract lock for this repository.
//
// Usage:
//   node tool/generate_api_models.mjs          # regenerate lib/core/api/generated
//   node tool/generate_api_models.mjs --check  # fail if regenerating would change output (drift check)
//
// Scope: only the Auth and Driver operations actually consumed by DRIVER-APP-01
// (see contract/lock.json -> includedPaths). No endpoint is invented; every path
// and schema below is copied from the real OpenAPI document.

import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const specPath = path.resolve(repoRoot, '../noki-shared-contracts/spec/openapi/noki-api.openapi.json');
const lockPath = path.resolve(repoRoot, 'contract/lock.json');
const outDir = path.resolve(repoRoot, 'lib/core/api/generated');

const checkMode = process.argv.includes('--check');

function sha256(buffer) {
  return createHash('sha256').update(buffer).digest('hex');
}

const lock = JSON.parse(readFileSync(lockPath, 'utf8'));

if (!existsSync(specPath)) {
  console.error(`FATAL: canonical OpenAPI spec not found at ${specPath}`);
  console.error('This generator only reads the checked-in noki-shared-contracts spec. It never guesses endpoints.');
  process.exit(1);
}

const specRaw = readFileSync(specPath);
const specChecksum = sha256(specRaw);

if (specChecksum !== lock.openapiChecksum) {
  console.error('FATAL: OpenAPI checksum mismatch.');
  console.error(`  expected (contract/lock.json): ${lock.openapiChecksum}`);
  console.error(`  actual   (spec file on disk):  ${specChecksum}`);
  console.error('Refusing to generate Dart models against an unlocked/unexpected API surface.');
  process.exit(1);
}

const spec = JSON.parse(specRaw.toString('utf8'));

// ---------------------------------------------------------------------------
// Whitelisted operations. Nothing outside this list is generated or consumed.
// ---------------------------------------------------------------------------
const includedOperationIds = new Set(lock.includedOperationIds);

const usedSchemaNames = new Set();
const operations = [];

for (const [pathKey, pathItem] of Object.entries(spec.paths)) {
  for (const [method, op] of Object.entries(pathItem)) {
    if (!op || typeof op !== 'object' || !op.operationId) continue;
    if (!includedOperationIds.has(op.operationId)) continue;

    const requestSchema = op.requestBody?.content?.['application/json']?.schema ?? null;
    const responseSchema = op.responses?.['200']?.content?.['application/json']?.schema ?? null;
    const params = (op.parameters ?? []).map((p) => ({
      name: p.name,
      in: p.in,
      required: !!p.required,
      schema: p.schema,
    }));

    operations.push({
      operationId: op.operationId,
      method: method.toUpperCase(),
      path: pathKey,
      summary: op.summary ?? '',
      params,
      requestSchema,
      responseSchema,
    });

    collectSchemaRefs(requestSchema, usedSchemaNames);
    collectSchemaRefs(responseSchema, usedSchemaNames);
  }
}

// Validate that every whitelisted operationId was actually found (fail loud on drift).
const foundIds = new Set(operations.map((o) => o.operationId));
for (const id of includedOperationIds) {
  if (!foundIds.has(id)) {
    console.error(`FATAL: operationId "${id}" listed in contract/lock.json was not found in the canonical OpenAPI document.`);
    console.error('The backend surface has drifted from the mobile lock. Update contract/lock.json deliberately, do not guess.');
    process.exit(1);
  }
}

function collectSchemaRefs(schema, into) {
  if (!schema || typeof schema !== 'object') return;
  if (schema.$ref) {
    const name = schema.$ref.split('/').pop();
    if (!into.has(name)) {
      into.add(name);
      collectSchemaRefs(spec.components.schemas[name], into);
    }
    return;
  }
  if (schema.allOf) for (const s of schema.allOf) collectSchemaRefs(s, into);
  if (schema.items) collectSchemaRefs(schema.items, into);
  if (schema.properties) for (const p of Object.values(schema.properties)) collectSchemaRefs(p, into);
}

// ---------------------------------------------------------------------------
// Dart type mapping
// ---------------------------------------------------------------------------

function dartClassName(name) {
  // Drop the "Dto" suffix noise for readability but keep names unique/traceable.
  return name;
}

function resolveType(schema, propName, className) {
  if (!schema) return { dart: 'dynamic', kind: 'dynamic' };
  if (schema.$ref) {
    const name = schema.$ref.split('/').pop();
    return { dart: dartClassName(name), kind: 'ref', refName: name };
  }
  if (schema.allOf) {
    // NestJS/Swagger emits `nullable + allOf:[$ref]` for optional nested objects.
    const inner = schema.allOf.find((s) => s.$ref);
    if (inner) return resolveType(inner, propName, className);
  }
  if (schema.type === 'array') {
    const item = resolveType(schema.items, propName, className);
    return { dart: 'List<${item}>'.replace('${item}', item.dart), kind: 'array', item };
  }
  if (schema.type === 'string') {
    if (Array.isArray(schema.enum)) {
      return { dart: `${className}${capitalize(propName)}`, kind: 'enum', values: schema.enum };
    }
    return { dart: 'String', kind: 'scalar' };
  }
  if (schema.type === 'number') return { dart: 'num', kind: 'scalar' };
  if (schema.type === 'boolean') return { dart: 'bool', kind: 'scalar' };
  if (schema.type === 'object' && !schema.properties) {
    // Swagger's representation of a nullable freeform value (backend fields such
    // as `email`, `deliveryProfileId`) - every real example on the contract is a
    // plain string, so this is generated as a nullable String.
    return { dart: 'String', kind: 'scalar' };
  }
  return { dart: 'dynamic', kind: 'dynamic' };
}

function capitalize(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

// Collect enum types across all used schemas so each is only emitted once.
const enumRegistry = new Map(); // dartName -> values[]

function registerEnumsIn(resolved) {
  if (resolved.kind === 'enum') {
    enumRegistry.set(resolved.dart, resolved.values);
  }
  if (resolved.kind === 'array') {
    registerEnumsIn(resolved.item);
  }
}

function propertiesOf(schemaName) {
  const schema = spec.components.schemas[schemaName];
  const required = new Set(schema.required ?? []);
  const props = schema.properties ?? {};
  return Object.entries(props).map(([propName, propSchema]) => {
    const resolved = resolveType(propSchema, propName, schemaName);
    const nullable = !required.has(propName) || propSchema.nullable === true;
    registerEnumsIn(resolved);
    return { propName, propSchema, resolved, nullable };
  });
}

function dartFieldName(name) {
  // All current schema property names are already valid lowerCamelCase Dart identifiers.
  return name;
}

function emitEnum(dartName, values) {
  const memberFor = (v) => v
    .split(/[_\s]+/)
    .map((part, i) => (i === 0 ? part.toLowerCase() : capitalize(part.toLowerCase())))
    .join('');
  const members = values.map(memberFor);
  const lines = [];
  lines.push(`enum ${dartName} {`);
  for (const m of members) lines.push(`  ${m},`);
  lines.push('  unknown;');
  lines.push('');
  lines.push(`  static ${dartName} fromJson(String value) {`);
  lines.push('    switch (value) {');
  values.forEach((v, i) => {
    lines.push(`      case ${JSON.stringify(v)}:`);
    lines.push(`        return ${dartName}.${members[i]};`);
  });
  lines.push('      default:');
  lines.push(`        return ${dartName}.unknown;`);
  lines.push('    }');
  lines.push('  }');
  lines.push('');
  lines.push('  String toJson() {');
  lines.push('    switch (this) {');
  values.forEach((v, i) => {
    lines.push(`      case ${dartName}.${members[i]}:`);
    lines.push(`        return ${JSON.stringify(v)};`);
  });
  lines.push(`      case ${dartName}.unknown:`);
  lines.push(`        return ${JSON.stringify(values[0])};`);
  lines.push('    }');
  lines.push('  }');
  lines.push('}');
  return lines.join('\n');
}

function emitClass(schemaName) {
  const fields = propertiesOf(schemaName);
  const lines = [];
  lines.push(`class ${schemaName} {`);
  lines.push(`  const ${schemaName}({`);
  for (const f of fields) {
    lines.push(`    ${f.nullable ? '' : 'required '}this.${dartFieldName(f.propName)},`);
  }
  lines.push('  });');
  lines.push('');
  for (const f of fields) {
    const type = f.resolved.dart + (f.nullable ? '?' : '');
    lines.push(`  final ${type} ${dartFieldName(f.propName)};`);
  }
  lines.push('');
  lines.push(`  factory ${schemaName}.fromJson(Map<String, dynamic> json) {`);
  lines.push(`    return ${schemaName}(`);
  for (const f of fields) {
    lines.push(`      ${dartFieldName(f.propName)}: ${fromJsonExpr(f, `json[${JSON.stringify(f.propName)}]`)},`);
  }
  lines.push('    );');
  lines.push('  }');
  lines.push('');
  lines.push('  Map<String, dynamic> toJson() {');
  lines.push('    return {');
  for (const f of fields) {
    lines.push(`      ${JSON.stringify(f.propName)}: ${toJsonExpr(f, dartFieldName(f.propName))},`);
  }
  lines.push('    };');
  lines.push('  }');
  lines.push('}');
  return lines.join('\n');
}

function fromJsonExpr(field, accessor) {
  const { resolved, nullable } = field;
  if (resolved.kind === 'ref') {
    const expr = `${resolved.refName}.fromJson(${accessor} as Map<String, dynamic>)`;
    return nullable ? `${accessor} == null ? null : ${expr}` : expr;
  }
  if (resolved.kind === 'enum') {
    const expr = `${resolved.dart}.fromJson(${accessor} as String)`;
    return nullable ? `${accessor} == null ? null : ${expr}` : expr;
  }
  if (resolved.kind === 'array') {
    const itemExpr = fromJsonExpr({ resolved: resolved.item, nullable: false }, 'e');
    const listExpr = `(${accessor} as List<dynamic>).map((e) => ${itemExpr}).toList()`;
    return nullable ? `${accessor} == null ? null : ${listExpr}` : listExpr;
  }
  if (resolved.dart === 'num') return `(${accessor} as num?)${nullable ? '' : '!'}`;
  if (resolved.dart === 'bool') return `${accessor} as bool${nullable ? '?' : ''}`;
  // String / dynamic
  return `${accessor} as ${resolved.dart}${nullable ? '?' : ''}`;
}

function toJsonExpr(field, accessor) {
  const { resolved, nullable } = field;
  if (resolved.kind === 'ref' || resolved.kind === 'enum') {
    return nullable ? `${accessor}?.toJson()` : `${accessor}.toJson()`;
  }
  if (resolved.kind === 'array') {
    const itemExpr = toJsonExpr({ resolved: resolved.item, nullable: false }, 'e');
    const listExpr = `${accessor}.map((e) => ${itemExpr}).toList()`;
    return nullable ? `${accessor} == null ? null : ${listExpr}` : listExpr;
  }
  return accessor;
}

// ---------------------------------------------------------------------------
// Emit files
// ---------------------------------------------------------------------------

const classNames = [...usedSchemaNames].sort();
const classBodies = classNames.map((n) => emitClass(n));
const enumBodies = [...enumRegistry.entries()]
  .sort((a, b) => a[0].localeCompare(b[0]))
  .map(([name, values]) => emitEnum(name, values));

const header = `// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Produced by tool/generate_api_models.mjs from the canonical OpenAPI document
// locked in contract/lock.json. Run:
//   node tool/generate_api_models.mjs
// to regenerate, or:
//   node tool/generate_api_models.mjs --check
// to detect drift in CI.
`;

const modelsFile = [
  header,
  '// ignore_for_file: type=lint',
  '',
  ...enumBodies,
  '',
  ...classBodies,
].join('\n\n');

const opsFile = [
  header,
  '// Machine-readable description of every generated operation, consumed by',
  '// lib/core/api/driver_api_client.dart. Kept separate from the client itself',
  '// so the client stays hand-written and reviewable.',
  '',
  'class GeneratedApiOperation {',
  '  const GeneratedApiOperation({',
  '    required this.operationId,',
  '    required this.method,',
  '    required this.path,',
  '  });',
  '',
  '  final String operationId;',
  '  final String method;',
  '  final String path;',
  '}',
  '',
  'const List<GeneratedApiOperation> generatedApiOperations = [',
  ...operations
    .sort((a, b) => a.operationId.localeCompare(b.operationId))
    .map(
      (o) =>
        `  GeneratedApiOperation(operationId: ${JSON.stringify(o.operationId)}, method: ${JSON.stringify(
          o.method,
        )}, path: ${JSON.stringify(o.path)}),`,
    ),
  '];',
].join('\n');

const lockFile = [
  header,
  'class ApiContractLock {',
  `  static const String apiHead = ${JSON.stringify(lock.apiHead)};`,
  `  static const String contractsVersion = ${JSON.stringify(lock.contractsVersion)};`,
  `  static const String openapiChecksum = ${JSON.stringify(lock.openapiChecksum)};`,
  `  static const String generator = ${JSON.stringify(lock.generator)};`,
  `  static const String generatorVersion = ${JSON.stringify(lock.generatorVersion)};`,
  '}',
].join('\n');

const outputs = {
  'driver_models.generated.dart': modelsFile + '\n',
  'driver_operations.generated.dart': opsFile + '\n',
  'api_contract_lock.generated.dart': lockFile + '\n',
};

if (checkMode) {
  let drift = false;
  for (const [file, content] of Object.entries(outputs)) {
    const target = path.join(outDir, file);
    const current = existsSync(target) ? readFileSync(target, 'utf8') : null;
    if (current !== content) {
      console.error(`DRIFT: ${path.relative(repoRoot, target)} is out of date. Run: node tool/generate_api_models.mjs`);
      drift = true;
    }
  }
  if (drift) process.exit(1);
  console.log(`OK: generated Dart models match the canonical OpenAPI document (checksum ${specChecksum}).`);
  process.exit(0);
}

mkdirSync(outDir, { recursive: true });
for (const [file, content] of Object.entries(outputs)) {
  writeFileSync(path.join(outDir, file), content);
}

console.log(`Generated ${Object.keys(outputs).length} file(s) into ${path.relative(repoRoot, outDir)}`);
console.log(`  classes: ${classNames.length}, enums: ${enumRegistry.size}, operations: ${operations.length}`);
console.log(`  source checksum: ${specChecksum}`);
