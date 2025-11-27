#!/bin/bash
set -e

echo "=========================================="
echo "PostgreSQL AI Extension - Local Test"
echo "=========================================="
echo ""

# Configuration
CONTAINER_NAME="postgres-ai-test"
POSTGRES_PASSWORD="testpass123"
POSTGRES_DB="testdb"
TEST_PORT="5433"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# Trap cleanup on exit
trap cleanup EXIT

echo "Step 1: Building Docker image..."
docker build -t postgres-ai-query:test .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Image built successfully${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo ""
echo "Step 2: Starting container..."
docker run -d \
    --name $CONTAINER_NAME \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -e POSTGRES_DB=$POSTGRES_DB \
    -e OPENAI_API_KEY="test-key" \
    -e AI_DEFAULT_MODEL="gpt-4o" \
    -p $TEST_PORT:5432 \
    postgres-ai-query:test

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container started${NC}"
else
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
fi

echo ""
echo "Step 3: Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if docker exec $CONTAINER_NAME pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "Step 4: Checking extension installation..."
EXTENSION_CHECK=$(docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -t -c "SELECT COUNT(*) FROM pg_available_extensions WHERE name = 'pg_ai_query';" | xargs)

if [ "$EXTENSION_CHECK" == "1" ]; then
    echo -e "${GREEN}✓ pg_ai_query extension is available${NC}"
else
    echo -e "${RED}✗ Extension not found${NC}"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo ""
echo "Step 5: Verifying extension is created..."
EXTENSION_CREATED=$(docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -t -c "SELECT COUNT(*) FROM pg_extension WHERE extname = 'pg_ai_query';" | xargs)

if [ "$EXTENSION_CREATED" == "1" ]; then
    echo -e "${GREEN}✓ Extension is created and loaded${NC}"
else
    echo -e "${RED}✗ Extension is available but not created${NC}"
    exit 1
fi

echo ""
echo "Step 6: Checking available functions..."
FUNCTION_COUNT=$(docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -t -c "SELECT COUNT(*) FROM pg_proc WHERE proname LIKE 'generate_query' OR proname LIKE 'explain_query' OR proname LIKE 'get_database_tables' OR proname LIKE 'get_table_details';" | xargs)

if [ "$FUNCTION_COUNT" -gt "0" ]; then
    echo -e "${GREEN}✓ Found $FUNCTION_COUNT AI query functions${NC}"
    echo ""
    echo "Available functions:"
    docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -c "
        SELECT
            proname AS function_name,
            pg_get_function_identity_arguments(oid) AS arguments
        FROM pg_proc
        WHERE proname IN ('generate_query', 'explain_query', 'get_database_tables', 'get_table_details')
        ORDER BY proname, pronargs;
    "
else
    echo -e "${RED}✗ No functions found${NC}"
    exit 1
fi

echo ""
echo "Step 7: Testing basic functionality..."
echo "Creating a test table..."
docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -c "
    CREATE TABLE IF NOT EXISTS test_users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100),
        created_at TIMESTAMP DEFAULT NOW()
    );
"

echo ""
echo "Testing get_database_tables()..."
docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -c "SELECT get_database_tables();"

echo ""
echo "Testing get_table_details()..."
docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -c "SELECT get_table_details('test_users');"

echo ""
echo "=========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "=========================================="
echo ""
echo "Container is still running for manual testing:"
echo "  Connection: psql \"postgresql://postgres:$POSTGRES_PASSWORD@localhost:$TEST_PORT/$POSTGRES_DB\""
echo "  Stop container: docker stop $CONTAINER_NAME"
echo ""
echo "Note: To test AI query generation, you need to set a valid API key:"
echo "  docker exec $CONTAINER_NAME psql -U postgres -d $POSTGRES_DB -c \"SELECT generate_query('show all tables', 'your-api-key', 'openai');\""
echo ""

# Remove trap so container stays running
trap - EXIT

echo -e "${YELLOW}Run 'docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME' to clean up${NC}"
