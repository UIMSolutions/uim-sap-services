# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-06

### Added
- Initial release of UIM SAP HANA Cloud Library
- SAP HANA Cloud client with HTTP/REST API support
- Multiple authentication methods (Basic Auth, OAuth2, JWT, API Key, Certificate)
- SQL query builder with fluent API
- Transaction support (ACID)
- Table, view, and column metadata operations
- Connection configuration and management
- Comprehensive exception handling
- Prepared statement support
- Batch query execution
- Connection retry logic and timeout management
- Schema and database introspection
- Full integration with uim-framework and vibe.d

### Features
- `SAPHanaClient`: Main client for database operations
- `AuthManager`: Authentication and authorization handling
- `QueryBuilder`: Fluent SQL query construction
- `ConnectionConfig`: Connection configuration management
- `Credential`: Multiple authentication credential types
- `QueryResult`: Structured query results with metadata
- Exception hierarchy: `SAPException`, `SAPAuthenticationException`, `SAPConnectionException`, `SAPQueryException`

### Documentation
- Comprehensive README with examples
- Code examples for all major features
- API documentation in source code
- Quick start guide

## [Unreleased]

### Planned
- Connection pooling
- Async/await support for non-blocking operations
- Stored procedure support
- Advanced query optimization hints
- Result set streaming for large datasets
- Trigger management
- User and role management
- Backup and restore operations
- Performance monitoring and statistics
- Query plan analysis
- More comprehensive test suite
