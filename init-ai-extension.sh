#!/bin/sh
set -e

echo "Initializing pg_ai_query extension..."

# Copy config file to postgres user home directory if it exists
if [ -f /var/lib/postgresql/config/pg_ai.config ]; then
    echo "Copying pg_ai.config to postgres home directory..."
    cp /var/lib/postgresql/config/pg_ai.config /var/lib/postgresql/.pg_ai.config
    chown postgres:postgres /var/lib/postgresql/.pg_ai.config
    chmod 600 /var/lib/postgresql/.pg_ai.config
    echo "Configuration file copied successfully."
else
    echo "No custom configuration found. Extension will use default settings."
    echo "You can configure API keys later by setting environment variables."
fi

# Automatically create extension in the default database
if [ -n "$POSTGRES_DB" ]; then
    echo "Creating pg_ai_query extension in database: $POSTGRES_DB"
    psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS pg_ai_query;

        -- Show available functions
        SELECT 'pg_ai_query extension installed successfully!' AS status;
        SELECT 'Available functions:' AS info;
        SELECT proname AS function_name, pg_get_function_identity_arguments(oid) AS arguments
        FROM pg_proc
        WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        AND proname LIKE '%query%' OR proname LIKE '%explain%' OR proname LIKE '%database%' OR proname LIKE '%table%';
EOSQL

    if [ $? -eq 0 ]; then
        echo "✓ pg_ai_query extension created successfully!"
    else
        echo "✗ Warning: Could not create extension automatically."
        echo "  You can create it manually with: CREATE EXTENSION pg_ai_query;"
    fi
else
    echo "No default database specified. You'll need to create the extension manually."
fi

echo ""
echo "=========================================="
echo "PostgreSQL AI Query Extension Ready!"
echo "=========================================="
echo ""
echo "Quick Start:"
echo "  1. Set your API key (OpenAI or Anthropic)"
echo "  2. Connect to your database"
echo "  3. Run: SELECT generate_query('your natural language query');"
echo ""
echo "Example queries:"
echo "  SELECT generate_query('show all tables');"
echo "  SELECT get_database_tables();"
echo "  SELECT explain_query('SELECT * FROM users LIMIT 10');"
echo ""
echo "Documentation: https://benodiwal.github.io/pg_ai_query/"
echo "=========================================="
