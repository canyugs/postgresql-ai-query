FROM postgres:17-alpine

LABEL maintainer="PostgreSQL AI Extension"
LABEL description="PostgreSQL with pg_ai_query extension for AI-powered SQL generation"
LABEL pg_ai_query.source="https://github.com/canyugs/pg_ai_query"
LABEL pg_ai_query.branch="fix/gcc-compatibility"

# Install build dependencies and runtime dependencies
RUN apk add --no-cache \
    libcurl \
    openssl \
    libstdc++ \
    && apk add --no-cache --virtual .build-deps \
    git \
    cmake \
    make \
    g++ \
    postgresql-dev \
    curl-dev \
    openssl-dev \
    linux-headers

# Clone pg_ai_query from fork with GCC compatibility fix
RUN git clone --depth 1 --recurse-submodules --shallow-submodules \
    --branch fix/gcc-compatibility \
    https://github.com/canyugs/pg_ai_query.git /tmp/pg_ai_query

WORKDIR /tmp/pg_ai_query

# Build the extension with GCC
# CMAKE_POSITION_INDEPENDENT_CODE=ON is required for ARM64 to link static libs into shared object
RUN mkdir build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$(pg_config --pkglibdir) \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_CXX_FLAGS="-fPIC" \
    -DCMAKE_C_FLAGS="-fPIC" \
    -DAI_SDK_BUILD_EXAMPLES=OFF \
    -DAI_SDK_BUILD_TESTS=OFF \
    -DBUILD_SHARED_LIBS=OFF && \
    make -j$(nproc) pg_ai_query && \
    make install

# Copy SQL files and prompts to extension directory
RUN cp sql/pg_ai_query--1.0.sql $(pg_config --sharedir)/extension/ && \
    cp pg_ai_query.control $(pg_config --sharedir)/extension/ && \
    mkdir -p $(pg_config --sharedir)/extension/prompts && \
    cp -r prompts/* $(pg_config --sharedir)/extension/prompts/ 2>/dev/null || true

# Create directory for config files
RUN mkdir -p /var/lib/postgresql/config

# Clean up build dependencies and temporary files
RUN apk del .build-deps && \
    rm -rf /tmp/* /var/cache/apk/*

# Copy initialization script
COPY init-ai-extension.sh /docker-entrypoint-initdb.d/10-init-ai-extension.sh
RUN chmod +x /docker-entrypoint-initdb.d/10-init-ai-extension.sh

# Copy example config template
COPY pg_ai.config.template /etc/postgresql/pg_ai.config.template

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD pg_isready -U postgres || exit 1

# Use the default postgres entrypoint
CMD ["postgres"]
