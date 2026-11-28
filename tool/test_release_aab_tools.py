#!/usr/bin/env python3
"""Targeted tests for Android release AAB verification and workflow input guards.

Run with:
  python3 -m unittest -v tool/test_release_aab_tools.py
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
VERIFY_SCRIPT = REPO_ROOT / "tool" / "verify_release_aab.py"
WORKFLOW_FILE = REPO_ROOT / ".github" / "workflows" / "android-release-aab.yml"
EXPECTED_PACKAGE = "com.agrismartchain.noki.noki_driver_app"


def _encode_varint(value: int) -> bytes:
    out = bytearray()
    while True:
        chunk = value & 0x7F
        value >>= 7
        if value:
            out.append(chunk | 0x80)
        else:
            out.append(chunk)
            return bytes(out)


def _encode_len_delim(field_num: int, payload: bytes) -> bytes:
    return _encode_varint((field_num << 3) | 2) + _encode_varint(len(payload)) + payload


def _encode_varint_field(field_num: int, value: int) -> bytes:
    return _encode_varint((field_num << 3) | 0) + _encode_varint(value)


def build_proto_manifest(package: str, version_code: int, version_name: str) -> bytes:
    """Build a minimal aapt.pb.XmlNode manifest matching `aapt2 --proto-format`."""
    android_ns = b"http://schemas.android.com/apk/res/android"

    pkg_attr = _encode_len_delim(2, b"package") + _encode_len_delim(3, package.encode("utf-8"))

    vc_prim = _encode_varint_field(6, version_code)
    vc_item = _encode_len_delim(7, vc_prim)
    vc_attr = (
        _encode_len_delim(1, android_ns)
        + _encode_len_delim(2, b"versionCode")
        + _encode_len_delim(3, str(version_code).encode("utf-8"))
        + _encode_len_delim(6, vc_item)
    )

    vn_attr = (
        _encode_len_delim(1, android_ns)
        + _encode_len_delim(2, b"versionName")
        + _encode_len_delim(3, version_name.encode("utf-8"))
    )

    manifest_elem = (
        _encode_len_delim(3, b"manifest")
        + _encode_len_delim(4, pkg_attr)
        + _encode_len_delim(4, vc_attr)
        + _encode_len_delim(4, vn_attr)
    )
    return _encode_len_delim(1, manifest_elem)


def extract_validate_step_script(workflow_path: Path) -> str:
    """Extract the exact `run: |` block of the `Validate inputs and required signing secrets` step."""
    lines = workflow_path.read_text(encoding="utf-8").splitlines()
    in_step = False
    in_run = False
    run_indent: int | None = None
    script_lines: list[str] = []

    for line in lines:
        if not in_step:
            if "name: Validate inputs and required signing secrets" in line:
                in_step = True
            continue

        if not in_run:
            if line.strip() == "run: |":
                in_run = True
            continue

        if line.strip() == "":
            script_lines.append("")
            continue

        indent = len(line) - len(line.lstrip(" "))
        if run_indent is None:
            run_indent = indent
        if indent < run_indent:
            break
        script_lines.append(line[run_indent:])

    if not script_lines:
        raise AssertionError("Could not extract Validate step script from workflow YAML")
    return "\n".join(script_lines) + "\n"


class VerifyReleaseAabTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp_dir = Path(self._tmp.name)
        self.keystore = self.tmp_dir / "upload.jks"
        self.store_pass = "TestStorePass123!"
        self.alias = "upload"

        subprocess.run(
            [
                "keytool",
                "-genkeypair",
                "-noprompt",
                "-storetype",
                "jks",
                "-keystore",
                str(self.keystore),
                "-storepass",
                self.store_pass,
                "-keypass",
                self.store_pass,
                "-alias",
                self.alias,
                "-keyalg",
                "RSA",
                "-keysize",
                "2048",
                "-validity",
                "365",
                "-dname",
                "CN=NOKI Upload Test, O=Agrismartchain, C=CG",
            ],
            check=True,
            capture_output=True,
            text=True,
        )

        list_out = subprocess.run(
            [
                "keytool",
                "-J-Duser.language=en",
                "-J-Duser.country=US",
                "-list",
                "-v",
                "-keystore",
                str(self.keystore),
                "-alias",
                self.alias,
                "-storepass",
                self.store_pass,
            ],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
        match = re.search(r"^\s*SHA256:\s*([0-9A-Fa-f:]+)\s*$", list_out, re.MULTILINE)
        self.assertIsNotNone(match, f"Failed to read cert SHA256 from keytool output:\n{list_out}")
        self.cert_sha256 = match.group(1)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def _create_signed_aab(
        self,
        filename: str,
        *,
        package: str = EXPECTED_PACKAGE,
        version_code: int = 1,
        version_name: str = "0.1.0",
    ) -> Path:
        aab = self.tmp_dir / filename
        manifest_bytes = build_proto_manifest(package, version_code, version_name)
        with zipfile.ZipFile(aab, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("base/manifest/AndroidManifest.xml", manifest_bytes)
            zf.writestr("base/dex/classes.dex", b"fake-dex-payload")

        subprocess.run(
            [
                "jarsigner",
                "-keystore",
                str(self.keystore),
                "-storepass",
                self.store_pass,
                "-keypass",
                self.store_pass,
                str(aab),
                self.alias,
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        return aab

    def _run_verifier(
        self,
        aab: Path,
        *,
        expected_package: str = EXPECTED_PACKAGE,
        expected_version_code: int = 1,
        expected_cert_sha256: str | None = None,
    ) -> subprocess.CompletedProcess[str]:
        cmd = [
            sys.executable,
            str(VERIFY_SCRIPT),
            "--aab",
            str(aab),
            "--expected-package",
            expected_package,
            "--expected-version-code",
            str(expected_version_code),
        ]
        if expected_cert_sha256 is not None:
            cmd.extend(["--expected-cert-sha256", expected_cert_sha256])
        return subprocess.run(cmd, capture_output=True, text=True, check=False)

    def test_accepts_self_signed_upload_cert_matching_expected_fingerprint(self) -> None:
        aab = self._create_signed_aab("valid.aab")
        res = self._run_verifier(aab, expected_cert_sha256=self.cert_sha256)
        self.assertEqual(res.returncode, 0, msg=f"stdout={res.stdout}\nstderr={res.stderr}")
        payload = json.loads(res.stdout)
        self.assertEqual(payload["package"], EXPECTED_PACKAGE)
        self.assertEqual(payload["versionCode"], 1)
        self.assertEqual(payload["signerCertSha256"], self.cert_sha256.upper())

    def test_rejects_unsigned_entry_added_after_signing(self) -> None:
        aab = self._create_signed_aab("tampered.aab")
        # Append an unsigned entry AFTER signing; jarsigner alone still prints
        # "jar verified." and exits 0, so verify_release_aab.py must reject it.
        with zipfile.ZipFile(aab, "a", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("base/assets/unsigned_injected.txt", b"injected-after-signing")

        res = self._run_verifier(aab, expected_cert_sha256=self.cert_sha256)
        self.assertNotEqual(res.returncode, 0, "Expected verifier to reject bundle with unsigned entry")
        self.assertIn("unsigned", res.stderr.lower())


class WorkflowBuildNumberValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.validate_script = extract_validate_step_script(WORKFLOW_FILE)

    def _run_validate_step(self, build_number: str, *, include_secrets: bool = True) -> tuple[int, str, str, str]:
        with tempfile.TemporaryDirectory() as tmp:
            gh_output = Path(tmp) / "github_output"
            gh_output.write_text("", encoding="utf-8")
            env = {
                "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
                "GITHUB_OUTPUT": str(gh_output),
                "INPUT_BUILD_NUMBER": build_number,
                "NOKI_DRIVER_RELEASE_KEYSTORE_BASE64": "ZHVtbXk=" if include_secrets else "",
                "NOKI_DRIVER_RELEASE_STORE_PASSWORD": "dummy" if include_secrets else "",
                "NOKI_DRIVER_RELEASE_KEY_ALIAS": "dummy" if include_secrets else "",
                "NOKI_DRIVER_RELEASE_KEY_PASSWORD": "dummy" if include_secrets else "",
            }
            res = subprocess.run(
                ["bash", "-c", self.validate_script],
                env=env,
                capture_output=True,
                text=True,
                check=False,
            )
            return res.returncode, res.stdout, res.stderr, gh_output.read_text(encoding="utf-8")

    def test_accepts_valid_boundaries(self) -> None:
        for valid in ("1", "2100000000"):
            with self.subTest(build_number=valid):
                rc, stdout, stderr, output = self._run_validate_step(valid)
                self.assertEqual(rc, 0, msg=f"stdout={stdout}\nstderr={stderr}")
                self.assertIn(f"build_number={valid}", output)

    def test_rejects_out_of_range_and_64bit_overflow_values(self) -> None:
        for invalid in ("2100000001", "18446744073709551617", "0", "-1", "01", "9999999999", "12abc"):
            with self.subTest(build_number=invalid):
                rc, stdout, stderr, _ = self._run_validate_step(invalid)
                self.assertNotEqual(rc, 0, msg=f"Expected rejection for build_number={invalid!r}")
                self.assertIn("Invalid build_number", stdout + stderr)

    def test_rejects_missing_signing_secrets(self) -> None:
        rc, stdout, stderr, _ = self._run_validate_step("1", include_secrets=False)
        self.assertNotEqual(rc, 0)
        self.assertIn("Missing required GitHub Actions signing secret(s)", stdout + stderr)


if __name__ == "__main__":
    unittest.main()
