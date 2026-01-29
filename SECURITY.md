# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Security Measures

### 1. Container Security

- **Base Images**: Using official Microsoft DevContainer images
- **No Root User**: Container runs as `vscode` user (non-root)
- **Minimal Attack Surface**: Only necessary tools installed
- **Read-only Mounts**: SSH keys mounted as read-only

### 2. Secrets Management

- **Environment Variables**: Sensitive data stored in `.env` (git-ignored)
- **No Hardcoded Secrets**: API keys configured via environment
- **`.gitignore`**: Comprehensive patterns to prevent secret leaks

### 3. Network Security

- **Internal Network**: Containers communicate via Docker network
- **Minimal Port Exposure**: Only proxy port 8083 exposed to host
- **No Direct Internet**: Proxy mediates all LLM API calls

### 4. Dependency Management

- **Version Pinning**: ✅ Versions pinned with ARG variables in Dockerfile
- **SHA256 Verification**: ⚠️ Partial - Some binaries verified
- **Minimal Dependencies**: Only essential packages installed
- **No Piped Installs**: ✅ Download then execute (safer)

### 5. Code Quality

- **Linting**: Python code linted with `pylint` and `black`
- **Editor Config**: Consistent formatting via EditorConfig
- **Spell Checking**: Code spell checker enabled

## Known Limitations

### Current State

1. ✅ **Version Pinning**: Tool versions pinned with ARG (uv, Node.js)
2. ⚠️ **SHA256 Checks**: Partial implementation (needs completion)
3. **No Image Scanning**: Docker images not scanned for vulnerabilities
4. ✅ **No Piped Installs**: Downloads saved then executed
5. ✅ **Shell Safety**: SHELL with pipefail configured

### Planned Improvements

- [x] Add version pinning with ARG variables
- [x] Remove piped bash installations
- [x] Add SHELL with pipefail
- [ ] Complete SHA256 verification for all downloads
- [ ] Implement Hadolint for Dockerfile linting
- [ ] Add Trivy for container scanning

## Reporting a Vulnerability

If you discover a security vulnerability:

1. **Do NOT** open a public issue
2. Contact the maintainer privately
3. Provide detailed description and reproduction steps
4. Allow reasonable time for fix before disclosure

## Security Best Practices

### For Users

1. **Never commit `.env` files**: Contains API keys
2. **Review mounted volumes**: Understand what's shared with container
3. **Use read-only mounts**: For sensitive data like SSH keys
4. **Rotate API keys**: Periodically change LLM API keys
5. **Monitor proxy logs**: Check for suspicious activity

### For Developers

1. **Review dependencies**: Before adding new packages
2. **Use specific versions**: Pin versions in requirements
3. **Run linters**: Before committing code
4. **Check `.dockerignore`**: Prevent sensitive files in images
5. **Test in isolation**: Use separate test API keys

## Security Tools

### Available

- **Black**: Python code formatter
- **Pylint**: Python linter
- **Prettier**: JSON/YAML formatter
- **EditorConfig**: Consistent file formatting

### Recommended (TODO)

- **Hadolint**: Dockerfile linter
- **Trivy**: Container vulnerability scanner
- **Bandit**: Python security linter
- **Safety**: Python dependency security checker

## Compliance

This project follows security best practices for:
- Docker container development
- Python development
- DevContainer specifications
- Secrets management

## License

Security policies are subject to the same license as the project.
