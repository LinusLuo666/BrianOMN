# 🕐 Cron 表达式解析工具

一个简单易用的 Cron 表达式解析工具，支持中文解释和未来执行时间预测。

## 功能特性

- ✅ **Cron 表达式解析** - 支持 Quartz 规范的 Cron 表达式
- ✅ **中文自然语言描述** - 将 Cron 表达式转换为易懂的中文描述
- ✅ **执行时间预测** - 显示未来 5 次执行时间
- ✅ **响应式界面** - 支持桌面和移动设备
- ✅ **Docker 一键部署** - 支持容器化部署

## 快速开始

### 使用 Docker Compose（推荐）

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd BrianOMN
   ```

2. **一键启动**
   ```bash
   docker-compose up -d
   ```

3. **访问应用**
   打开浏览器访问：http://localhost

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

## Cron 表达式示例

| 表达式 | 描述 |
|--------|------|
| `0 0 4 * * ?` | 每天凌晨4点 |
| `0 30 9 * * MON-FRI` | 工作日上午9:30 |
| `0 0 */6 * * ?` | 每6小时 |
| `0 0 0 1 * ?` | 每月1日凌晨 |
| `0 15 10 ? * MON-FRI` | 工作日上午10:15 |

## 项目结构

```
├── backend/                 # Spring Boot 后端
│   ├── src/main/java/       # Java 源码
│   ├── pom.xml             # Maven 配置
│   └── Dockerfile          # 后端镜像配置
├── frontend/               # 前端
│   ├── index.html          # 主页面
│   ├── nginx.conf          # Nginx 配置
│   └── Dockerfile          # 前端镜像配置
├── docker-compose.yml      # 容器编排
└── README.md              # 项目文档
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

## 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 修改 docker-compose.yml 中的端口映射
   ports:
     - "8080:80"  # 将前端改为 8080 端口
   ```

2. **后端健康检查失败**
   ```bash
   # 检查后端日志
   docker logs cron-tools-backend
   ```

3. **跨域问题**
   - 确保前端和后端在同一域名下，或者修改后端 CORS 配置

### 日志查看

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
```

## 开发模式

1. **后端开发**
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```

2. **前端开发**
   ```bash
   cd frontend
   # 修改 index.html 中 API_BASE 为 'http://localhost:8080/api'
   python -m http.server 3000
   ```

## 部署到生产环境

### EC2 Ubuntu 部署

1. **安装 Docker**
   ```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose
   sudo systemctl enable --now docker
   ```

2. **部署应用**
   ```bash
   git clone <repository-url>
   cd BrianOMN
   sudo docker-compose up -d
   ```

3. **配置域名（可选）**
   - 绑定域名到 EC2 公网 IP
   - 使用 Let's Encrypt 配置 HTTPS

## 许可证

MIT License

---

**快速测试**: 访问 http://localhost 并输入 `0 0 4 * * ?` 进行测试！