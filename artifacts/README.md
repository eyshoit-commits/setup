# Offline Installation Artifacts

This directory is used to store offline installers for air-gapped or restricted network environments.

## Supported Artifacts

Place the following files here for offline installation:

### NVM
- `nvm-{version}.tar.gz` - NVM archive
- Extract from: https://github.com/nvm-sh/nvm/releases

### Miniconda
- `miniconda.sh` - Miniconda installer for your platform
- Download from: https://docs.conda.io/en/latest/miniconda.html
  - Linux x86_64: `Miniconda3-latest-Linux-x86_64.sh`
  - macOS x86_64: `Miniconda3-latest-MacOSX-x86_64.sh`
  - macOS arm64: `Miniconda3-latest-MacOSX-arm64.sh`

### UV
- `uv-installer.sh` - UV installer script
- Download from: https://astral.sh/uv/install.sh

### Rustup
- `rustup-init.sh` - Rustup installer
- Download from: https://sh.rustup.rs

## Usage

When the setup scripts detect files in this directory, they will automatically use local installers instead of downloading from the internet.

Example:
```bash
# Download artifacts
cd artifacts/
curl -LO https://astral.sh/uv/install.sh
mv install.sh uv-installer.sh

# Run setup (will use local artifacts)
cd ..
bash scripts/setup.sh
```

## .gitkeep

The `.gitkeep` file ensures this directory is tracked by git even when empty. Actual installer files should NOT be committed to the repository due to size.
