# 🕐 Cron 表达式解析工具

一个基于 Spring Boot + Vue.js 的 Cron 表达式解析和时间预测工具。

## ✨ 功能特性

- ✅ **Cron 表达式解析** - 支持 Quartz 格式，生成中文描述
- ✅ **执行时间预测** - 显示未来 N 次执行时间
- ✅ **多时区支持** - 支持自定义时区设置
- ✅ **响应式界面** - 现代化的 Web 界面
- ✅ **Docker 部署** - 容器化部署，开箱即用
- ✅ **单元测试** - 核心功能完整测试覆盖

## 🚀 快速部署（推荐）

### 方式一：一键部署脚本

1. **克隆项目**
   ```bash
   git clone https://github.com/LinusLuo666/BrianOMN.git
   cd BrianOMN
   ```

2. **运行部署脚本**
   ```bash
   ./deploy.sh
   ```

   脚本会自动：
   - 检查并安装 Docker 和 Docker Compose
   - 构建并启动所有服务
   - 进行健康检查
   - 显示访问地址

3. **访问应用**
   - 前端：http://YOUR_SERVER_IP
   - 后端：http://YOUR_SERVER_IP:8080

### 方式二：手动 Docker 部署

```bash
# 克隆项目
git clone https://github.com/LinusLuo666/BrianOMN.git
cd BrianOMN

# 启动服务
docker-compose up -d --build

# 查看状态
docker-compose ps
```

### 手动部署

#### 后端部署

1. **环境要求**
   - Java 17+
   - Maven 3.6+

2. **构建并运行**
   ```bash
   cd backend
   ./mvnw clean package
   java -jar target/cron-parser-api-1.0.0.jar
   ```

3. **验证后端**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

#### 前端部署

1. **使用任意 Web 服务器**
   ```bash
   cd frontend
   # 使用 Python
   python -m http.server 3000
   
   # 或使用 Node.js
   npx serve .
   ```

2. **修改 API 地址**
   如果后端不在同一域名，需要修改 `frontend/index.html` 中的 `API_BASE` 变量。

## API 文档

### 解析 Cron 表达式

```
GET /api/parse?expr=0 0 4 * * ?
```

**响应示例：**
```json
{
  "expr": "0 0 4 * * ?",
  "type": "QUARTZ", 
  "timezone": "Asia/Shanghai",
  "humanReadable": "每天 04:00 执行",
  "valid": true,
  "message": ""
}
```

### 获取未来执行时间

```
GET /api/next-times?expr=0 0 4 * * ?&count=5
```

**响应示例：**
```json
{
  "nextTimes": [
    "2025-08-17 04:00:00 (Asia/Shanghai)",
    "2025-08-18 04:00:00 (Asia/Shanghai)",
    "2025-08-19 04:00:00 (Asia/Shanghai)",
    "2025-08-20 04:00:00 (Asia/Shanghai)",
    "2025-08-21 04:00:00 (Asia/Shanghai)"
  ],
  "valid": true,
  "message": ""
}
```

## 🧪 测试

### 运行单元测试
```bash
cd backend
./mvnw test
```

### 测试覆盖的功能
- ✅ Cron 表达式解析（各种格式）
- ✅ 执行时间计算
- ✅ 异常处理
- ✅ API 接口测试
- ✅ 时区处理

## 🔧 常用 Cron 示例

| 表达式 | 描述 |
|--------|------|
| `0 0 4 * * ?` | 每天凌晨4点 |
| `0 30 9 ? * MON-FRI` | 工作日上午9:30 |
| `0 0 0/6 * * ?` | 每6小时 |
| `0 0 12 ? * SUN` | 每周日中午12点 |
| `0 15 10 ? * *` | 每天上午10:15 |

## 项目结构

```
BrianOMN/
├── backend/                 # Spring Boot 后端
│   ├── src/main/java/      # 主要代码
│   ├── src/test/java/      # 单元测试
│   └── Dockerfile          # 后端镜像
├── frontend/               # 前端页面
│   ├── index.html         # 主页面
│   ├── nginx.conf         # Nginx 配置
│   └── Dockerfile         # 前端镜像
├── docker-compose.yml     # 容器编排
├── deploy.sh             # 一键部署脚本
└── README.md             # 项目文档
```

## 技术栈

- **后端**: Spring Boot 3.x + cron-utils
- **前端**: 原生 HTML/CSS/JavaScript
- **容器**: Docker + Nginx
- **Java版本**: 17

## 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `APP_DEFAULT_TIMEZONE` | `Asia/Shanghai` | 默认时区 |
| `SPRING_PROFILES_ACTIVE` | - | Spring 配置文件 |

## 🐳 Docker 命令

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 更新代码并重新部署
git pull && docker-compose up -d --build
```

## ⚠️ 注意事项

1. **Quartz Cron 语法**：
   - 不能同时指定 day-of-month 和 day-of-week
   - 其中一个必须用 `?` 占位符
   - 步长语法：`起始值/步长`（如 `0/6`）

2. **常见错误**：
   - ❌ `0 30 9 * * MON-FRI` 
   - ✅ `0 30 9 ? * MON-FRI`
   - ❌ `0 0 */6 * * ?`
   - ✅ `0 0 0/6 * * ?`

## 🔍 故障排除

### 查看容器状态
```bash
docker-compose ps
```

### 查看后端日志
```bash
docker-compose logs backend
```

### 查看前端日志
```bash
docker-compose logs frontend
```

### 重启单个服务
```bash
docker-compose restart backend
```

### 完全清理重建
```bash
docker-compose down --rmi all --volumes
docker-compose up -d --build
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License