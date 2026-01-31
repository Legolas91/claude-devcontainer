# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Security Measures

### 1. Container Security

- **Base Images**: Using official Microsoft DevContainer images
- **Root User**: Container runs as `root` for proxy management
- **Minimal Attack Surface**: Only necessary tools installed
- **Read-only Mounts**: SSH keys mounted as read-only

### 2. Secrets Management

- **Environment Variables**: Sensitive data stored in `.env` (git-ignored)
- **No Hardcoded Secrets**: API keys configured via environment
- **`.gitignore`**: Comprehensive patterns to prevent secret leaks

### 3. Network Security

- **Single Container**: Proxy runs inside the same container
- **Minimal Port Exposure**: Only proxy port 8082 exposed to host
- **No Direct Internet**: Proxy mediates all LLM API calls

### 4. Dependency Management

- **Go Proxy Binary**: ✅ Pre-compiled binary, no runtime dependencies
- **Minimal Dependencies**: Only essential packages installed (curl, jq, nodejs)
- **No Piped Installs**: ✅ Download then execute (safer)

## Known Limitations

### Current State

1. ✅ **Go Proxy Binary**: Pre-compiled, statically linked, no runtime dependencies
2. **No Image Scanning**: Docker images not scanned for vulnerabilities
3. ✅ **Minimal Dependencies**: Only curl, jq, nodejs installed

### Planned Improvements

- [x] Use pre-compiled Go proxy (no runtime dependencies)
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
5. **Monitor proxy logs**: Check for suspicious activity (`cat /tmp/claude-code-proxy.log`)

### For Developers

1. **Review dependencies**: Before adding new packages
2. **Check `.dockerignore`**: Prevent sensitive files in images
3. **Test in isolation**: Use separate test API keys

## Security Tools

### Recommended (TODO)

- **Hadolint**: Dockerfile linter
- **Trivy**: Container vulnerability scanner

## Compliance

This project follows security best practices for:
- Docker container development
- DevContainer specifications
- Secrets management

## License

Security policies are subject to the same license as the project.
