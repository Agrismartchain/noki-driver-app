#!/usr/bin/env python3
"""Verify a signed Android App Bundle (.aab) before uploading it as a CI artifact.

Checks performed directly on the final .aab binary:
  1. Parses base/manifest/AndroidManifest.xml (aapt.pb.XmlNode proto format)
     and verifies `package` and `android:versionCode`.
  2. Verifies cryptographic JAR signature integrity via `jarsigner -verify`.
  3. Inspects the signing certificate via `keytool -printcert -jarfile`,
     rejecting Android Debug certificates and asserting an exact SHA-256
     fingerprint match when `--expected-cert-sha256` is supplied.
  4. Computes the SHA-256 digest and size of the .aab file.

Standard-library Python 3 + JDK keytool/jarsigner only; no third-party deps.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import zipfile
from typing import Any


def read_varint(buf: bytes, index: int) -> tuple[int, int]:
    shift = 0
    value = 0
    while True:
        byte = buf[index]
        index += 1
        value |= (byte & 0x7F) << shift
        if not (byte & 0x80):
            return value, index
        shift += 7


def parse_proto_fields(buf: bytes) -> list[tuple[int, int, Any]]:
    index = 0
    length = len(buf)
    fields: list[tuple[int, int, Any]] = []
    while index < length:
        tag, index = read_varint(buf, index)
        field_num = tag >> 3
        wire_type = tag & 7
        if wire_type == 0:
            val, index = read_varint(buf, index)
        elif wire_type == 1:
            val, index = buf[index : index + 8], index + 8
        elif wire_type == 2:
            size, index = read_varint(buf, index)
            val, index = buf[index : index + size], index + size
        elif wire_type == 5:
            val, index = buf[index : index + 4], index + 4
        else:
            raise ValueError(f"Unsupported protobuf wire type: {wire_type}")
        fields.append((field_num, wire_type, val))
    return fields


def parse_aab_manifest(aab_path: str) -> dict[str, Any]:
    with zipfile.ZipFile(aab_path, "r") as zf:
        manifest_entry = "base/manifest/AndroidManifest.xml"
        if manifest_entry not in zf.namelist():
            raise RuntimeError(f"Missing {manifest_entry} inside {aab_path}")
        raw = zf.read(manifest_entry)

    root_elem = next(
        (v for fn, wt, v in parse_proto_fields(raw) if fn == 1 and wt == 2),
        None,
    )
    if root_elem is None:
        raise RuntimeError("Root XmlElement not found in proto AndroidManifest.xml")

    elem_fields = parse_proto_fields(root_elem)
    elem_name = next(
        (v.decode("utf-8") for fn, wt, v in elem_fields if fn == 3 and wt == 2),
        None,
    )
    if elem_name != "manifest":
        raise RuntimeError(f"Expected root element 'manifest', got {elem_name!r}")

    attrs: dict[str, Any] = {}
    for fn, wt, raw_attr in elem_fields:
        if fn != 4 or wt != 2:
            continue
        af = parse_proto_fields(raw_attr)
        ns = next((v.decode("utf-8") for f, w, v in af if f == 1 and w == 2), "")
        name = next((v.decode("utf-8") for f, w, v in af if f == 2 and w == 2), "")
        str_val = next((v.decode("utf-8") for f, w, v in af if f == 3 and w == 2), None)
        compiled = next((v for f, w, v in af if f == 6 and w == 2), None)
        int_val = None
        if compiled is not None:
            prim = next((v for f, w, v in parse_proto_fields(compiled) if f == 7 and w == 2), None)
            if prim is not None:
                int_val = next((v for f, w, v in parse_proto_fields(prim) if f in (6, 7) and w == 0), None)
        key = f"android:{name}" if ns.endswith("/android") else name
        attrs[key] = int_val if int_val is not None else str_val

    return {
        "package": attrs.get("package"),
        "versionCode": int(attrs["android:versionCode"]) if attrs.get("android:versionCode") is not None else None,
        "versionName": attrs.get("android:versionName"),
    }


def normalise_fingerprint(fp: str) -> str:
    return re.sub(r"[^0-9A-Fa-f]", "", fp).upper()


SIGNATURE_META_RE = re.compile(
    r"^META-INF/(MANIFEST\.MF|SIG-[^/]+|[^/]+\.(SF|RSA|DSA|EC))$",
    re.IGNORECASE,
)


def is_signature_metadata(entry_name: str) -> bool:
    return bool(SIGNATURE_META_RE.match(entry_name))


def parse_manifest_entries(aab_path: str) -> set[str]:
    with zipfile.ZipFile(aab_path, "r") as zf:
        if "META-INF/MANIFEST.MF" not in zf.namelist():
            raise RuntimeError("Missing META-INF/MANIFEST.MF in signed bundle")
        raw = zf.read("META-INF/MANIFEST.MF").decode("utf-8", errors="replace")

    unfolded_lines: list[str] = []
    for line in raw.replace("\r\n", "\n").split("\n"):
        if line.startswith(" ") and unfolded_lines:
            unfolded_lines[-1] += line[1:]
        else:
            unfolded_lines.append(line)

    entries: set[str] = set()
    for line in unfolded_lines:
        if line.startswith("Name: "):
            entries.add(line[len("Name: ") :])
    return entries


def verify_signature(aab_path: str, expected_cert_sha256: str | None) -> dict[str, str]:
    jarsigner = subprocess.run(
        [
            "jarsigner",
            "-J-Duser.language=en",
            "-J-Duser.country=US",
            "-verify",
            "-verbose",
            "-certs",
            aab_path,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    combined_output = f"{jarsigner.stdout}\n{jarsigner.stderr}"
    if jarsigner.returncode != 0 or "jar verified." not in jarsigner.stdout:
        raise RuntimeError(
            "jarsigner verification failed:\n"
            f"stdout: {jarsigner.stdout[-1500:]}\n"
            f"stderr: {jarsigner.stderr[-1500:]}"
        )

    if "unsigned entries" in combined_output.lower():
        raise RuntimeError(
            "AAB contains unsigned entries that are not integrity-checked by jarsigner"
        )

    # Parse every entry line emitted by `jarsigner -verify -verbose`:
    #   <flags> <size> <timestamp...> <entry_name>
    # Example: `sm       5 Sat Nov 28 09:11:36 UTC 2026 base/manifest/AndroidManifest.xml`
    entry_line_re = re.compile(
        r"^(?P<flags>[ smk?iX]{6})\s*\d+\s+[A-Z][a-z]{2}\s+[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\s+\S+\s+\d{4}\s+(?P<name>.+)$"
    )
    signed_entries: set[str] = set()
    unsigned_entries: list[str] = []
    for line in jarsigner.stdout.splitlines():
        match = entry_line_re.match(line)
        if not match:
            continue
        flags = match.group("flags")
        name = match.group("name")
        if name.endswith("/") or is_signature_metadata(name):
            continue
        if "?" in flags or "s" not in flags or "m" not in flags:
            unsigned_entries.append(name)
        else:
            signed_entries.add(name)

    if unsigned_entries:
        raise RuntimeError(
            f"AAB contains unsigned or unverified entries: {', '.join(sorted(unsigned_entries))}"
        )

    # Cross-check every non-directory, non-signature ZIP member against both
    # META-INF/MANIFEST.MF and the verified `sm` entries from jarsigner.
    manifest_entries = parse_manifest_entries(aab_path)
    with zipfile.ZipFile(aab_path, "r") as zf:
        payload_entries = {
            info.filename
            for info in zf.infolist()
            if not info.is_dir() and not is_signature_metadata(info.filename)
        }

    missing_from_manifest = sorted(payload_entries - manifest_entries)
    if missing_from_manifest:
        raise RuntimeError(
            f"AAB contains entries missing from META-INF/MANIFEST.MF: {', '.join(missing_from_manifest)}"
        )

    missing_from_signed = sorted(payload_entries - signed_entries)
    if missing_from_signed:
        raise RuntimeError(
            f"AAB contains entries not verified as signed by jarsigner: {', '.join(missing_from_signed)}"
        )

    printcert = subprocess.run(
        [
            "keytool",
            "-J-Duser.language=en",
            "-J-Duser.country=US",
            "-printcert",
            "-jarfile",
            aab_path,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if printcert.returncode != 0:
        raise RuntimeError(f"keytool -printcert failed: {printcert.stderr}")

    owner_match = re.search(r"^\s*Owner:\s*(.+)$", printcert.stdout, re.MULTILINE)
    sha256_match = re.search(r"^\s*SHA256:\s*([0-9A-Fa-f:]+)\s*$", printcert.stdout, re.MULTILINE)
    if not owner_match or not sha256_match:
        raise RuntimeError(f"Could not extract signer Owner/SHA256 from keytool output:\n{printcert.stdout}")

    owner = owner_match.group(1).strip()
    cert_sha256 = sha256_match.group(1).strip().upper()

    if "CN=Android Debug" in owner:
        raise RuntimeError(f"Refusing debug-signed bundle (signer: {owner})")

    if expected_cert_sha256:
        if normalise_fingerprint(cert_sha256) != normalise_fingerprint(expected_cert_sha256):
            raise RuntimeError(
                "AAB signing certificate SHA-256 does not match the configured upload keystore alias: "
                f"got {cert_sha256}, expected {expected_cert_sha256}"
            )

    return {"owner": owner, "certSha256": cert_sha256}


def sha256_file(path: str) -> str:
    digest = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify signed Android release .aab")
    parser.add_argument("--aab", required=True, help="Path to the signed .aab file")
    parser.add_argument("--expected-package", required=True, help="Expected Android applicationId/package")
    parser.add_argument("--expected-version-code", required=True, type=int, help="Expected android:versionCode")
    parser.add_argument("--expected-cert-sha256", default=None, help="Expected signing certificate SHA-256 fingerprint")
    parser.add_argument("--json-out", default=None, help="Optional path to write verification metadata JSON")
    args = parser.parse_args()

    if not os.path.isfile(args.aab):
        raise SystemExit(f"ERROR: AAB file not found: {args.aab}")

    manifest = parse_aab_manifest(args.aab)
    if manifest["package"] != args.expected_package:
        raise SystemExit(
            f"ERROR: Package mismatch: expected {args.expected_package!r}, got {manifest['package']!r}"
        )
    if manifest["versionCode"] != args.expected_version_code:
        raise SystemExit(
            f"ERROR: versionCode mismatch: expected {args.expected_version_code}, got {manifest['versionCode']}"
        )
    if not manifest["versionName"]:
        raise SystemExit("ERROR: android:versionName is missing in AAB manifest")

    signature = verify_signature(args.aab, args.expected_cert_sha256)
    file_sha256 = sha256_file(args.aab)
    file_size = os.path.getsize(args.aab)

    result = {
        "aabFile": os.path.basename(args.aab),
        "sizeBytes": file_size,
        "sha256": file_sha256,
        "package": manifest["package"],
        "versionName": manifest["versionName"],
        "versionCode": manifest["versionCode"],
        "signerOwner": signature["owner"],
        "signerCertSha256": signature["certSha256"],
    }

    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as fh:
            json.dump(result, fh, indent=2)
            fh.write("\n")

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
