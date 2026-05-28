# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this template, please report it responsibly.

**Do not open a public issue.**

Instead, email **mitch@mrosmarin.com** with:

- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

You should receive a response within 48 hours. We'll work with you to understand
the issue and coordinate a fix before any public disclosure.

## Scope

This template includes shell scripts that run with user privileges inside a
devcontainer. Security concerns include:

- Scripts that download and execute code from the internet (install scripts in `postinstall.sh`)
- SSH key generation and GitHub authentication (`ssh-setup.sh`)
- File permissions and secrets handling (`.env` files, `.gitignore` patterns)
- Claude Code permission settings (allow/deny lists in `settings.json`)

## Best Practices for Users

- Review `postinstall.sh` before building the devcontainer
- Never commit `.env`, `.env.local`, or `.devcontainer/.env`
- Rotate SSH keys if a container is compromised
- Audit Claude Code permissions periodically with `make claude-audit`
