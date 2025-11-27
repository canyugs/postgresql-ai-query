# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Initial Release - v1.0.0 (TBD)

#### Added
- PostgreSQL 17 Alpine-based Docker image with pg_ai_query extension
- Automatic extension compilation and installation
- Support for OpenAI (GPT-4o, GPT-4, GPT-3.5-turbo) models
- Support for Anthropic (Claude 3.5 Sonnet) models
- Natural language to SQL query generation
- AI-powered query performance analysis
- Automatic database schema discovery
- Configuration file support with environment variable substitution
- Zeabur PREBUILT_V2 template with multi-language support
- Comprehensive documentation in multiple languages (en-US, zh-TW, zh-CN, ja-JP)
- Automatic extension initialization on container startup
- Health check configuration
- Volume support for data persistence and configuration
- Environment variable configuration for API keys and models
- Row limit enforcement for safety (default: 1000 rows)
- Query validation and system table protection
- Detailed usage examples and troubleshooting guide
- Local testing script with automated verification
- Build and publish guide for Docker registries
- CI/CD workflow examples for GitHub Actions

#### Features
- **Query Generation Functions**
  - `generate_query(text)` - Basic query generation
  - `generate_query(text, text)` - With custom API key
  - `generate_query(text, text, text)` - With API key and provider selection

- **Performance Analysis Functions**
  - `explain_query(text)` - Analyze query performance
  - `explain_query(text, text)` - With custom API key
  - `explain_query(text, text, text)` - With API key and provider

- **Schema Discovery Functions**
  - `get_database_tables()` - List all database tables
  - `get_table_details(text)` - Get detailed table information

#### Configuration
- Configurable request timeout (default: 30 seconds)
- Configurable retry attempts (default: 3)
- Configurable row limits
- Optional query explanations
- Optional performance warnings
- Multiple response format options (plain SQL, JSON)

#### Documentation
- Comprehensive README with usage examples
- Quick start guide for rapid deployment
- Build and publish guide
- Implementation plan documentation
- Project summary with feature overview
- Automated test script
- Troubleshooting guide
- API reference

#### Security
- Environment variable-based API key management
- No hardcoded credentials
- Secure configuration file permissions
- System table access protection
- Query validation

#### Files
- `Dockerfile` - Multi-stage Alpine-based build
- `init-ai-extension.sh` - Automatic initialization script
- `pg_ai.config.template` - Configuration template
- `zeabur-template-postgresql-ai.yaml` - Zeabur deployment template
- `README.md` - Main documentation
- `BUILD.md` - Build and publish guide
- `QUICKSTART.md` - Quick start guide
- `SUMMARY.md` - Project overview
- `plan.md` - Implementation plan
- `test-local.sh` - Automated testing script
- `.dockerignore` - Docker build optimizations
- `CHANGELOG.md` - This file

## Future Roadmap

### Planned Features

#### v1.1.0
- [ ] Multi-stage Docker build for smaller image size
- [ ] Additional AI provider support (Google Gemini, Azure OpenAI)
- [ ] Query result caching mechanism
- [ ] Rate limiting for API requests
- [ ] Metrics and monitoring support (Prometheus)
- [ ] Query history logging

#### v1.2.0
- [ ] Query templating system
- [ ] Custom prompt engineering support
- [ ] Batch query generation
- [ ] Query validation before execution
- [ ] Cost estimation for API usage

#### v2.0.0
- [ ] Web UI for query management
- [ ] Query versioning and rollback
- [ ] Team collaboration features
- [ ] Advanced analytics dashboard
- [ ] Integration with popular BI tools

### Potential Improvements
- Performance optimizations for schema discovery
- Additional response format options
- Enhanced error messages with suggestions
- Support for more PostgreSQL versions
- ARM64 architecture optimization
- Kubernetes Helm chart

## Version History

### Version Numbering Scheme
- **Major version (X.0.0)**: Breaking changes, major new features
- **Minor version (0.X.0)**: New features, backwards compatible
- **Patch version (0.0.X)**: Bug fixes, minor improvements

### Release Process
1. Update CHANGELOG.md
2. Update version in Dockerfile labels
3. Build and test Docker image
4. Push to container registry
5. Update Zeabur template
6. Create GitHub release
7. Update documentation

## Notes

- This project is built on top of [pg_ai_query](https://github.com/benodiwal/pg_ai_query)
- PostgreSQL version: 17-alpine
- Base image is regularly updated for security patches
- API provider compatibility is tested with latest models

## Contributing

We welcome contributions! Please see our contributing guidelines for:
- Bug reports
- Feature requests
- Code contributions
- Documentation improvements

## Links

- GitHub Repository: (TBD)
- Docker Hub: (TBD)
- Zeabur Template: (TBD)
- Documentation: https://benodiwal.github.io/pg_ai_query/
