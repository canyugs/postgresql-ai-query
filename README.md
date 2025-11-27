# PostgreSQL with AI Query Extension

A powerful PostgreSQL 17 database with built-in [pg_ai_query](https://github.com/benodiwal/pg_ai_query) extension for generating SQL queries from natural language using OpenAI and Anthropic AI models.

## Features

- 🧠 **Natural Language to SQL**: Convert plain English descriptions into valid PostgreSQL queries
- 🤖 **Multiple AI Providers**: Support for both OpenAI (GPT-4o, GPT-4) and Anthropic (Claude) models
- 🔍 **Automatic Schema Discovery**: AI analyzes your database structure to understand tables and relationships
- 📊 **Query Performance Analysis**: Run EXPLAIN ANALYZE and get AI-powered optimization suggestions
- 🛡️ **Safety First**: Built-in protections with row limits and query validation
- ⚡ **PostgreSQL 17**: Latest stable PostgreSQL version with Alpine Linux base

## Quick Deploy on Zeabur

1. Click "Deploy" button to deploy from the Zeabur template marketplace
2. Set at least one API key:
   - **OPENAI_API_KEY**: Get from [OpenAI Platform](https://platform.openai.com/api-keys)
   - **ANTHROPIC_API_KEY**: Get from [Anthropic Console](https://console.anthropic.com/settings/keys)
3. Wait for deployment to complete
4. Connect to your database and start querying with AI!

## Manual Docker Build

If you want to build and run the Docker image locally:

```bash
# Clone this repository
cd postgresql-ai-query

# Build the Docker image
docker build -t postgres-ai-query:latest .

# Run the container
docker run -d \
  --name postgres-ai \
  -e POSTGRES_PASSWORD=yourpassword \
  -e OPENAI_API_KEY=your-openai-key \
  -e AI_DEFAULT_MODEL=gpt-4o \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  postgres-ai-query:latest
```

## Usage Examples

### Connect to Database

```bash
psql "postgresql://postgres:yourpassword@localhost:5432/mydb"
```

### Generate Queries from Natural Language

```sql
-- Simple queries
SELECT generate_query('show all customers');

-- Complex analytical queries
SELECT generate_query('monthly sales trend for the last year by category');

-- Business logic queries
SELECT generate_query('customers who have not placed orders in the last 6 months');

-- Data quality checks
SELECT generate_query('find duplicate email addresses in users table');
```

### Explore Database Schema

```sql
-- List all tables
SELECT get_database_tables();

-- Get detailed information about a specific table
SELECT get_table_details('users');
SELECT get_table_details('orders');
```

### Query Performance Analysis

```sql
-- Analyze a simple query
SELECT explain_query('SELECT * FROM users WHERE created_at > NOW() - INTERVAL ''7 days''');

-- Analyze complex queries with joins
SELECT explain_query('
    SELECT u.username, COUNT(o.id) as order_count
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id, u.username
    ORDER BY order_count DESC
');

-- Use specific AI provider
SELECT explain_query(
    'SELECT * FROM products WHERE price > 100',
    'your-api-key',
    'anthropic'
);
```

### Response Formats

By default, the extension returns SQL with explanations and warnings:

```sql
SELECT * FROM customers WHERE created_at >= NOW() - INTERVAL '7 days' LIMIT 1000;

-- Explanation:
-- Retrieves all customers who were created within the last 7 days

-- Warnings:
-- 1. Large dataset: Consider adding specific filters for better performance
```

## Configuration

The extension is pre-configured with sensible defaults through environment variables:

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENAI_API_KEY` | - | Your OpenAI API key |
| `ANTHROPIC_API_KEY` | - | Your Anthropic API key |
| `AI_DEFAULT_MODEL` | `gpt-4o` | Default OpenAI model to use |
| `ANTHROPIC_DEFAULT_MODEL` | `claude-3-5-sonnet-20241022` | Default Anthropic model to use |
| `POSTGRES_DB` | `mydb` | Database name |
| `POSTGRES_USER` | `postgres` | Database user |
| `POSTGRES_PASSWORD` | - | Database password (required) |

### Configuration File

The extension uses a configuration file at `/var/lib/postgresql/.pg_ai.config`:

```ini
[general]
log_level = "INFO"
enable_logging = true
request_timeout_ms = 30000
max_retries = 3

[query]
enforce_limit = true
default_limit = 1000

[response]
show_explanation = true
show_warnings = true
show_suggested_visualization = false
use_formatted_response = false

[openai]
api_key = "your-openai-key"
default_model = "gpt-4o"

[anthropic]
api_key = "your-anthropic-key"
default_model = "claude-3-5-sonnet-20241022"
```

## Available Functions

The extension provides the following SQL functions:

| Function | Description |
|----------|-------------|
| `generate_query(text)` | Generate SQL query from natural language |
| `generate_query(text, text)` | Generate query with custom API key |
| `generate_query(text, text, text)` | Generate query with API key and provider |
| `explain_query(text)` | Analyze query performance with AI insights |
| `explain_query(text, text)` | Analyze with custom API key |
| `explain_query(text, text, text)` | Analyze with API key and provider |
| `get_database_tables()` | List all tables in the database |
| `get_table_details(text)` | Get detailed information about a table |

## Use Cases

### 1. Data Analytics
```sql
-- Business Intelligence
SELECT generate_query('top 10 products by revenue this quarter');
SELECT generate_query('customer retention rate by month');
SELECT generate_query('average order value by customer segment');
```

### 2. Data Exploration
```sql
-- Discover data patterns
SELECT generate_query('show distribution of users by country');
SELECT generate_query('find outliers in product prices');
SELECT generate_query('most common order statuses');
```

### 3. Query Optimization
```sql
-- Get AI-powered optimization suggestions
SELECT explain_query('
    SELECT * FROM orders o
    JOIN users u ON o.user_id = u.id
    WHERE o.created_at > ''2024-01-01''
');
```

### 4. Data Quality
```sql
-- Find data issues
SELECT generate_query('find records with missing email addresses');
SELECT generate_query('identify users with duplicate phone numbers');
SELECT generate_query('check for invalid date ranges in orders');
```

## Security & Best Practices

### API Key Management
- ✅ Store API keys in environment variables, not in code
- ✅ Use separate API keys for development and production
- ✅ Monitor API usage and set spending limits
- ✅ Rotate API keys regularly

### Query Safety
- ✅ Row limit enforcement is enabled by default (1000 rows)
- ✅ System tables are protected from AI queries
- ✅ Generated queries are validated before execution
- ✅ Review generated queries before running in production

### Performance Considerations
- ⚠️ Each AI query consumes API credits
- ⚠️ AI requests add latency (typically 1-5 seconds)
- ⚠️ Consider caching common query patterns
- ⚠️ Use specific table/column names for better results

## Troubleshooting

### Extension not found
```sql
-- Check if extension is installed
SELECT * FROM pg_available_extensions WHERE name = 'pg_ai_query';

-- Create extension if needed
CREATE EXTENSION IF NOT EXISTS pg_ai_query;
```

### API key errors
```bash
# Verify API key is set
docker exec -it postgres-ai env | grep API_KEY

# Update configuration
docker exec -it postgres-ai psql -U postgres -c "
  SELECT generate_query('test query', 'your-new-api-key', 'openai');
"
```

### Connection issues
```bash
# Check if PostgreSQL is running
docker ps | grep postgres-ai

# Check logs
docker logs postgres-ai

# Test connection
psql "postgresql://postgres:password@localhost:5432/mydb"
```

## Documentation

- **pg_ai_query Documentation**: https://benodiwal.github.io/pg_ai_query/
- **GitHub Repository**: https://github.com/benodiwal/pg_ai_query
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/17/

## Files in This Template

```
postgresql-ai-query/
├── Dockerfile                    # Docker image for PostgreSQL with pg_ai_query
├── init-ai-extension.sh         # Initialization script
├── pg_ai.config.template        # Configuration file template
├── zeabur-template-postgresql-ai.yaml  # Zeabur deployment template
├── README.md                    # This file
├── plan.md                      # Implementation plan
└── .dockerignore               # Docker build exclusions
```

## Building and Publishing

### Build Docker Image

```bash
# Build for local testing
docker build -t postgres-ai-query:latest .

# Build for specific platform
docker build --platform linux/amd64 -t postgres-ai-query:latest .
```

### Push to Registry

```bash
# Docker Hub
docker tag postgres-ai-query:latest yourusername/postgres-ai-query:latest
docker push yourusername/postgres-ai-query:latest

# GitHub Container Registry
docker tag postgres-ai-query:latest ghcr.io/yourusername/postgres-ai-query:latest
docker push ghcr.io/yourusername/postgres-ai-query:latest
```

### Update Template

After pushing the image, update the `image` field in `zeabur-template-postgresql-ai.yaml`:

```yaml
spec:
  source:
    image: yourusername/postgres-ai-query:latest
```

## License

This template combines:
- PostgreSQL: PostgreSQL License
- pg_ai_query: See [LICENSE](https://github.com/benodiwal/pg_ai_query/blob/main/LICENSE)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

- For pg_ai_query issues: [GitHub Issues](https://github.com/benodiwal/pg_ai_query/issues)
- For Zeabur deployment issues: [Zeabur Support](https://zeabur.com/docs)
- For PostgreSQL questions: [PostgreSQL Community](https://www.postgresql.org/community/)
