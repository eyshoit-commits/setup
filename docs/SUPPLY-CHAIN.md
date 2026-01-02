# Supply Chain Security & Provenance Tracking

## Overview

This setup system implements comprehensive supply chain tracking to ensure transparency and security in the development environment setup process. Every installer, dependency, and artifact is tracked with cryptographic hashes and metadata.

## Provenance File (`provenance.json`)

The `provenance.json` file is automatically generated during setup and contains:

### Structure

```json
{
  "setup_id": "20260102-120000-a1b2c3",
  "timestamp": "2026-01-02T12:00:00Z",
  "host": {
    "hostname": "dev-machine-001",
    "os": "Linux",
    "arch": "x86_64",
    "user": "developer"
  },
  "installers": [
    {
      "name": "nvm",
      "version": "0.39.7",
      "source": "remote",
      "location": "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh",
      "sha256": "a1b2c3d4e5f6...",
      "verified": true
    }
  ],
  "integrity": {
    "all_verified": true,
    "failed_checks": [],
    "trust_level": "high"
  }
}
```

### Fields

- **setup_id**: Unique identifier for this setup run (timestamp + random hex)
- **timestamp**: ISO 8601 timestamp of when setup was initiated
- **host**: Information about the machine where setup was run
- **installers**: Array of all installers/artifacts used during setup
  - **name**: Tool name (e.g., "nvm", "miniconda")
  - **version**: Version installed
  - **source**: "remote" (downloaded) or "artifact" (local cache)
  - **location**: URL or file path
  - **sha256**: SHA-256 hash of the installer
  - **verified**: Boolean indicating if hash was successfully computed
- **integrity**: Overall integrity assessment
  - **all_verified**: True if all installers were verified
  - **failed_checks**: Array of any verification failures
  - **trust_level**: "high", "medium", or "low" based on verification status

## Trust Levels

### High Trust
- All installers downloaded from official sources
- All SHA-256 hashes computed and recorded
- No verification failures
- Setup completed successfully

### Medium Trust
- Some installers from cache/artifacts
- Most hashes verified
- Minor verification issues

### Low Trust
- Hash verification failures
- Unknown sources
- Incomplete setup

## Usage

### During Setup

Provenance tracking is automatic. The `record_installer()` function in `setup.sh` logs each installer:

```bash
record_installer "nvm" "$NVM_VERSION" "remote" "$NVM_INSTALLER"
```

### After Setup

Review the provenance file:

```bash
cat provenance.json | jq .
```

Check integrity status:

```bash
jq '.integrity' provenance.json
```

List all installers with hashes:

```bash
jq '.installers[] | {name, version, sha256}' provenance.json
```

## Supply Chain Security Benefits

1. **Auditability**: Complete record of what was installed and from where
2. **Reproducibility**: Exact versions and sources documented
3. **Verification**: SHA-256 hashes enable verification of downloads
4. **Incident Response**: Quickly identify affected systems if a supply chain attack is discovered
5. **Compliance**: Provides evidence for security audits and compliance requirements

## Integration with CI/CD

In CI/CD environments (REPRO mode), provenance tracking becomes even more critical:

- Strict version matching enforced
- Offline artifacts preferred
- Hash verification mandatory
- Any mismatch causes build failure

## Best Practices

1. **Store provenance files**: Commit to version control or artifact storage
2. **Review regularly**: Audit provenance for unexpected changes
3. **Compare across environments**: Ensure consistency between dev, staging, prod
4. **Rotate setup IDs**: Each setup run gets a unique ID for tracking
5. **Archive old provenance**: Keep historical records for forensics

## Example Workflow

```bash
# Run setup
./scripts/setup.sh

# Verify provenance
jq '.integrity.all_verified' provenance.json
# Output: true

# Check trust level
jq '.integrity.trust_level' provenance.json
# Output: "high"

# List all installers
jq '.installers[].name' provenance.json
# Output: "nvm", "miniconda", "rustup"

# Get SHA-256 for specific installer
jq '.installers[] | select(.name=="nvm") | .sha256' provenance.json
```

## Security Considerations

- **Hash Algorithm**: SHA-256 is used for cryptographic strength
- **Source Verification**: Always prefer official sources
- **Offline Artifacts**: Use trusted artifact caches in REPRO mode
- **Regular Updates**: Keep installer versions current for security patches

## Future Enhancements

- SLSA (Supply chain Levels for Software Artifacts) compliance
- Signature verification for downloaded installers
- Integration with vulnerability databases
- Automated hash verification against known-good values
- Provenance chain linking (parent/child setup relationships)
