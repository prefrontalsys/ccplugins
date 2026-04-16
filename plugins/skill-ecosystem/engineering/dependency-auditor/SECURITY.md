# Security Note — Intentionally Vulnerable Test Fixtures

This plugin is a dependency-vulnerability auditor. Its test fixtures at the following paths contain **deliberately outdated packages with known CVEs**:

- `test-project/package.json` — npm fixture with vulnerable versions of multer, axios, lodash, jsonwebtoken, webpack, mongoose, nodemailer, etc.
- `assets/sample_requirements.txt` — pip fixture with vulnerable versions of Django, cryptography, urllib3, requests, pytest, Pillow, django-allauth, etc.

These files exist so that the plugin's scanning logic has a known set of vulnerabilities to detect. **Bumping these versions breaks the tests.**

## For Dependabot / security scanners

GitHub Dependabot flags every package in these files. Alerts should be dismissed with reason:

- `tolerable_risk` — these are not installed or executed
- Or `not_used` — test fixture, not a real dependency

The plugin itself has no runtime dependencies and is not vulnerable.

## For contributors

If you need to update fixture packages (e.g. to add a new CVE to the detection suite), keep them pinned to vulnerable versions. Do not let a PR bump these files to "fix" a Dependabot alert.
