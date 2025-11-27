# Quick Start Guide

## 🚀 5 分鐘快速開始

### 選項 A: 使用 Zeabur 一鍵部署 (推薦)

1. **前往 Zeabur 模板市場**
   - 搜尋 "PostgreSQL AI"
   - 點擊 "Deploy"

2. **配置 API Key**
   ```
   OPENAI_API_KEY=sk-proj-xxxxx
   或
   ANTHROPIC_API_KEY=sk-ant-xxxxx
   ```

3. **開始使用**
   ```sql
   SELECT generate_query('show all tables');
   ```

### 選項 B: 本地 Docker 測試

1. **構建映像**
   ```bash
   cd postgresql-ai-query
   docker build -t postgres-ai-query:latest .
   ```

2. **運行容器**
   ```bash
   docker run -d \
     --name postgres-ai \
     -e POSTGRES_PASSWORD=yourpass \
     -e OPENAI_API_KEY=your-key \
     -p 5432:5432 \
     postgres-ai-query:latest
   ```

3. **連線測試**
   ```bash
   psql "postgresql://postgres:yourpass@localhost:5432/mydb" \
     -c "SELECT generate_query('show all tables');"
   ```

## 📚 常用 SQL 命令

### 查詢生成
```sql
-- 基礎查詢
SELECT generate_query('find all active users');

-- 分析查詢
SELECT generate_query('monthly sales trend for 2024');

-- 數據質量
SELECT generate_query('find duplicate emails');
```

### 資料探索
```sql
-- 列出所有表
SELECT get_database_tables();

-- 查看表結構
SELECT get_table_details('users');
```

### 效能優化
```sql
-- 分析查詢
SELECT explain_query('SELECT * FROM orders WHERE created_at > NOW() - INTERVAL ''7 days''');
```

## 🔑 API Key 設定

### OpenAI
1. 前往 https://platform.openai.com/api-keys
2. 建立新的 API Key
3. 設定環境變數: `OPENAI_API_KEY=sk-proj-xxxxx`

### Anthropic
1. 前往 https://console.anthropic.com/settings/keys
2. 建立新的 API Key
3. 設定環境變數: `ANTHROPIC_API_KEY=sk-ant-xxxxx`

## ⚙️ 環境變數速查

| 變數 | 必需 | 預設值 | 說明 |
|------|------|--------|------|
| `POSTGRES_PASSWORD` | ✅ | - | 資料庫密碼 |
| `OPENAI_API_KEY` | ⚠️ | - | OpenAI API 金鑰 |
| `ANTHROPIC_API_KEY` | ⚠️ | - | Anthropic API 金鑰 |
| `AI_DEFAULT_MODEL` | ❌ | `gpt-4o` | 預設模型 |
| `POSTGRES_DB` | ❌ | `mydb` | 資料庫名稱 |
| `POSTGRES_USER` | ❌ | `postgres` | 資料庫用戶 |

⚠️ 至少需要設定一個 AI API Key

## 🧪 測試指令

### 自動化測試
```bash
./test-local.sh
```

### 手動測試
```bash
# 1. 啟動容器
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=test \
  -e OPENAI_API_KEY=your-key \
  -p 5432:5432 \
  postgres-ai-query:latest

# 2. 等待就緒
docker exec test-postgres pg_isready

# 3. 測試連線
psql "postgresql://postgres:test@localhost:5432/mydb"

# 4. 測試擴展
psql "postgresql://postgres:test@localhost:5432/mydb" \
  -c "SELECT get_database_tables();"

# 5. 清理
docker stop test-postgres && docker rm test-postgres
```

## 📦 發布到 Registry

### Docker Hub
```bash
docker build -t yourusername/postgres-ai-query:latest .
docker push yourusername/postgres-ai-query:latest
```

### GitHub Container Registry
```bash
docker build -t ghcr.io/yourusername/postgres-ai-query:latest .
docker push ghcr.io/yourusername/postgres-ai-query:latest
```

### 更新模板
編輯 `zeabur-template-postgresql-ai.yaml`:
```yaml
spec:
  source:
    image: yourusername/postgres-ai-query:latest
```

## 🐛 故障排除

### 擴展未找到
```sql
-- 檢查擴展
SELECT * FROM pg_available_extensions WHERE name = 'pg_ai_query';

-- 手動創建
CREATE EXTENSION IF NOT EXISTS pg_ai_query;
```

### API Key 錯誤
```bash
# 檢查環境變數
docker exec postgres-ai env | grep API_KEY

# 更新 API Key
docker exec -it postgres-ai psql -U postgres -d mydb -c \
  "SELECT generate_query('test', 'your-new-key', 'openai');"
```

### 連線問題
```bash
# 檢查容器狀態
docker ps | grep postgres-ai

# 查看日誌
docker logs postgres-ai

# 測試網路
docker exec postgres-ai pg_isready -U postgres
```

## 📖 更多資源

- **完整文檔**: [README.md](README.md)
- **構建指南**: [BUILD.md](BUILD.md)
- **實作計劃**: [plan.md](plan.md)
- **專案總結**: [SUMMARY.md](SUMMARY.md)
- **官方文檔**: https://benodiwal.github.io/pg_ai_query/

## 💡 使用技巧

1. **清晰的自然語言**: 描述越具體,生成的查詢越準確
   ```sql
   -- ✅ 好的範例
   SELECT generate_query('find users who registered in the last 7 days and have made at least one purchase');

   -- ❌ 不好的範例
   SELECT generate_query('users');
   ```

2. **使用架構探索**: 先了解資料庫結構
   ```sql
   SELECT get_database_tables();
   SELECT get_table_details('your_table');
   ```

3. **審查生成的查詢**: 在生產環境執行前先檢查
   ```sql
   -- 先生成查詢
   SELECT generate_query('your query');

   -- 檢查並理解
   -- 然後手動執行
   ```

4. **效能優化**: 使用 explain_query 獲取建議
   ```sql
   SELECT explain_query('your slow query');
   ```

## 🎯 下一步

- [ ] 本地測試構建
- [ ] 設定 API Keys
- [ ] 測試 AI 查詢功能
- [ ] 推送映像到 Registry
- [ ] 更新模板 YAML
- [ ] 在 Zeabur 部署測試
- [ ] 完善文檔

開始使用吧! 🚀
