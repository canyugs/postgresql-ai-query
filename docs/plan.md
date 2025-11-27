# PostgreSQL AI Extension Template Plan

## 目標
建立一個 Zeabur 模板,提供預裝 `pg_ai_query` 擴展的 PostgreSQL 服務,讓用戶可以直接使用 AI 功能來生成和優化 SQL 查詢。

## 技術挑戰

### 1. 編譯擴展
`pg_ai_query` 是 C++ 擴展,需要編譯後才能安裝到 PostgreSQL:
- 需要 CMake 3.16+
- 需要 C++20 編譯器
- 需要 PostgreSQL 開發標頭檔
- 依賴第三方庫 (需要 `--recurse-submodules`)

### 2. 解決方案選項

#### 選項 A: 使用自定義 Dockerfile (推薦)
**優點:**
- 完全控制構建過程
- 可以預編譯擴展
- 可以預設配置文件
- 更新版本容易管理

**缺點:**
- 需要維護 Dockerfile
- 需要定期重建映像檔

**實作步驟:**
1. 建立 Dockerfile 基於 `postgres:17-alpine` 或 `postgres:17`
2. 安裝編譯依賴 (cmake, g++, make, postgresql-dev)
3. Clone `pg_ai_query` 並編譯
4. 安裝擴展到 PostgreSQL
5. 設置初始化腳本來創建擴展
6. 清理編譯依賴以減小映像大小

#### 選項 B: 使用 init script
**優點:**
- 使用官方 PostgreSQL 映像
- 簡單直接

**缺點:**
- 每次容器啟動都需要編譯 (不可行,太慢)
- 增加啟動時間

**結論:** 不推薦此選項

## 推薦架構

### 1. 建立自定義 Docker 映像

```dockerfile
FROM postgres:17-alpine

# 安裝構建依賴
RUN apk add --no-cache --virtual .build-deps \
    git cmake make g++ postgresql-dev curl-dev

# Clone 並編譯 pg_ai_query
WORKDIR /tmp
RUN git clone --recurse-submodules https://github.com/benodiwal/pg_ai_query.git
WORKDIR /tmp/pg_ai_query
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make && make install

# 清理構建依賴
RUN apk del .build-deps && \
    rm -rf /tmp/*

# 複製初始化腳本
COPY init-ai-extension.sh /docker-entrypoint-initdb.d/

# 複製配置文件模板
COPY pg_ai.config.template /etc/postgresql/
```

### 2. Zeabur Template 結構

```yaml
apiVersion: zeabur.com/v1
kind: Template
metadata:
    name: PostgreSQL with AI Query Extension
spec:
    description: PostgreSQL with pg_ai_query extension for AI-powered SQL generation
    services:
        - name: postgres-ai
          template: PREBUILT_V2
          spec:
            source:
                image: your-registry/postgres-ai-query:latest
            ports:
                - id: database
                  port: 5432
                  type: TCP
            volumes:
                - id: data
                  dir: /var/lib/postgresql/data
                - id: config
                  dir: /var/lib/postgresql/config
            env:
                POSTGRES_DB:
                    default: mydb
                POSTGRES_USER:
                    default: postgres
                POSTGRES_PASSWORD:
                    default: ${PASSWORD}
                # AI Provider 配置
                OPENAI_API_KEY:
                    default: ""
                    expose: true
                ANTHROPIC_API_KEY:
                    default: ""
                    expose: true
                AI_DEFAULT_PROVIDER:
                    default: "openai"
                AI_DEFAULT_MODEL:
                    default: "gpt-4o"
            configs:
                - path: /var/lib/postgresql/config/pg_ai.config
                  template: |
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
                    api_key = "${OPENAI_API_KEY}"
                    default_model = "${AI_DEFAULT_MODEL}"

                    [anthropic]
                    api_key = "${ANTHROPIC_API_KEY}"
                    default_model = "claude-3-5-sonnet-20241022"
                  permission: "0644"
                  envsubst: true
            instructions:
                - title: Enable AI Query Extension
                  content: |
                    Connect to your database and run:
                    CREATE EXTENSION IF NOT EXISTS pg_ai_query;
                - title: Test AI Query
                  content: |
                    SELECT generate_query('show all tables');
                - title: Configure API Keys
                  content: |
                    Set OPENAI_API_KEY or ANTHROPIC_API_KEY environment variables
```

### 3. 初始化腳本 (init-ai-extension.sh)

```bash
#!/bin/bash
set -e

# 複製配置文件到用戶目錄
if [ -f /var/lib/postgresql/config/pg_ai.config ]; then
    cp /var/lib/postgresql/config/pg_ai.config ~/.pg_ai.config
fi

# 創建擴展 (可選,讓用戶自己決定)
# psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
#     CREATE EXTENSION IF NOT EXISTS pg_ai_query;
# EOSQL

echo "pg_ai_query extension is available. Run 'CREATE EXTENSION pg_ai_query;' to enable it."
```

## 實作步驟

### Phase 1: 建立 Docker 映像
1. [ ] 建立 `postgresql-ai-query/Dockerfile`
2. [ ] 建立 `postgresql-ai-query/init-ai-extension.sh`
3. [ ] 建立 `postgresql-ai-query/pg_ai.config.template`
4. [ ] 測試本地構建

### Phase 2: 發布映像
1. [ ] 決定映像倉庫 (Docker Hub / GitHub Container Registry / Zeabur Registry)
2. [ ] 設置 CI/CD 自動構建
3. [ ] 推送映像

### Phase 3: 建立 Zeabur 模板
1. [ ] 建立 `postgresql-ai-query/zeabur-template.yaml`
2. [ ] 撰寫 README 文檔
3. [ ] 添加使用範例
4. [ ] 測試部署

### Phase 4: 文檔與範例
1. [ ] 撰寫快速開始指南
2. [ ] 提供 SQL 範例
3. [ ] 說明 API Key 配置
4. [ ] 性能考量說明

## 使用者體驗

### 用戶部署後的步驟:
1. 從 Zeabur 模板一鍵部署
2. 設置 OpenAI 或 Anthropic API Key
3. 連接到資料庫
4. 執行 `CREATE EXTENSION pg_ai_query;`
5. 開始使用 AI 查詢功能

### 範例查詢:
```sql
-- 生成查詢
SELECT generate_query('show all customers who registered in the last 30 days');

-- 分析查詢性能
SELECT explain_query('SELECT * FROM users WHERE created_at > NOW() - INTERVAL ''7 days''');

-- 獲取資料庫結構
SELECT get_database_tables();
```

## 注意事項

### 安全性
- API Key 應該透過環境變數設置
- 不要在模板中硬編碼 API Key
- 配置文件權限應該設為 0644
- 考慮添加 API 使用限制

### 效能
- 擴展會對每個查詢調用外部 API,會增加延遲
- 建議設置合理的 timeout (30秒)
- 考慮添加重試機制
- API 成本考量

### 維護
- 定期更新 pg_ai_query 版本
- 更新 PostgreSQL 基礎映像
- 監控擴展相容性
- 提供版本遷移指南

## 替代方案考量

### 方案 1: 僅提供安裝指南
不建立自定義映像,而是提供詳細的安裝指南讓用戶自行編譯。

**優點:** 不需要維護映像
**缺點:** 用戶體驗差,技術門檻高

### 方案 2: 使用 PostGIS 類似的架構
參考 PostGIS 的打包方式,提供預編譯的二進制包。

**優點:** 更專業的打包方式
**缺點:** 需要為不同平台編譯多個版本

## 建議

**最佳實作:** 選項 A (自定義 Dockerfile) + 完整的 Zeabur 模板

這個方案提供:
- ✅ 最佳的用戶體驗 (一鍵部署)
- ✅ 預編譯的擴展 (快速啟動)
- ✅ 靈活的配置 (環境變數 + config file)
- ✅ 清晰的文檔和範例
- ✅ 容易維護和更新

## 下一步

確認這個計劃後,我可以開始實作:
1. 建立 Dockerfile
2. 建立 Zeabur 模板 YAML
3. 撰寫文檔和範例
4. 測試完整流程
