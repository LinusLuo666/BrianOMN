#!/bin/bash

# 快速部署脚本 - 创建完整的项目结构
# 在服务器上运行此脚本以创建完整的 cron-tools 项目

set -e

echo "🚀 创建 Cron Tools 项目结构..."

# 创建项目根目录
PROJECT_DIR="$HOME/cron-tools"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

echo "📁 创建项目目录结构..."

# 创建后端目录结构
mkdir -p backend/src/main/java/com/crontools/app/{controller,service,model}
mkdir -p backend/src/main/resources
mkdir -p backend/.mvn/wrapper

# 创建前端目录
mkdir -p frontend

echo "📝 创建项目文件..."

# 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  backend:
    build: ./backend
    container_name: cron-tools-backend
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - APP_DEFAULT_TIMEZONE=Asia/Shanghai
    ports:
      - "8080:8080"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build: ./frontend
    container_name: cron-tools-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

networks:
  default:
    name: cron-tools-network
EOF

# 创建后端 pom.xml
cat > backend/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.crontools</groupId>
    <artifactId>cron-parser-api</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>com.cronutils</groupId>
            <artifactId>cron-utils</artifactId>
            <version>9.2.0</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 创建后端主应用类
cat > backend/src/main/java/com/crontools/app/CronToolsApplication.java << 'EOF'
package com.crontools.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CronToolsApplication {
    public static void main(String[] args) {
        SpringApplication.run(CronToolsApplication.class, args);
    }
}
EOF

# 创建配置文件
cat > backend/src/main/resources/application.properties << 'EOF'
server.port=8080
spring.application.name=cron-tools-api

spring.web.cors.allowed-origins=*
spring.web.cors.allowed-methods=GET,POST
spring.web.cors.allowed-headers=*

management.endpoints.web.exposure.include=health
management.endpoint.health.show-details=always

app.default.timezone=Asia/Shanghai

logging.level.com.crontools=INFO
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
EOF

# 创建响应模型类
cat > backend/src/main/java/com/crontools/app/model/CronParseResponse.java << 'EOF'
package com.crontools.app.model;

public class CronParseResponse {
    private String expr;
    private String type;
    private String timezone;
    private String humanReadable;
    private boolean valid;
    private String message;

    public CronParseResponse() {}

    public CronParseResponse(String expr, String type, String timezone, String humanReadable, boolean valid, String message) {
        this.expr = expr;
        this.type = type;
        this.timezone = timezone;
        this.humanReadable = humanReadable;
        this.valid = valid;
        this.message = message;
    }

    public String getExpr() { return expr; }
    public void setExpr(String expr) { this.expr = expr; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }
    public String getHumanReadable() { return humanReadable; }
    public void setHumanReadable(String humanReadable) { this.humanReadable = humanReadable; }
    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
EOF

cat > backend/src/main/java/com/crontools/app/model/NextTimesResponse.java << 'EOF'
package com.crontools.app.model;

import java.util.List;

public class NextTimesResponse {
    private List<String> nextTimes;
    private boolean valid;
    private String message;

    public NextTimesResponse() {}

    public NextTimesResponse(List<String> nextTimes, boolean valid, String message) {
        this.nextTimes = nextTimes;
        this.valid = valid;
        this.message = message;
    }

    public List<String> getNextTimes() { return nextTimes; }
    public void setNextTimes(List<String> nextTimes) { this.nextTimes = nextTimes; }
    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
EOF

echo "⏱️  创建服务类和控制器..."

# 创建 Cron 服务类（由于内容较长，分成多个部分）
cat > backend/src/main/java/com/crontools/app/service/CronService.java << 'EOF'
package com.crontools.app.service;

import com.cronutils.model.Cron;
import com.cronutils.model.CronType;
import com.cronutils.model.definition.CronDefinition;
import com.cronutils.model.definition.CronDefinitionBuilder;
import com.cronutils.model.time.ExecutionTime;
import com.cronutils.parser.CronParser;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class CronService {

    @Value("${app.default.timezone:Asia/Shanghai}")
    private String defaultTimezone;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public String parseCronToHuman(String cronExpression) {
        try {
            CronDefinition cronDefinition = CronDefinitionBuilder.instanceDefinitionFor(CronType.QUARTZ);
            CronParser parser = new CronParser(cronDefinition);
            Cron cron = parser.parse(cronExpression);
            cron.validate();
            
            return generateHumanReadable(cronExpression);
        } catch (Exception e) {
            throw new IllegalArgumentException("无效的 Cron 表达式: " + e.getMessage());
        }
    }

    public List<String> getNextExecutionTimes(String cronExpression, String timezone, int count) {
        try {
            CronDefinition cronDefinition = CronDefinitionBuilder.instanceDefinitionFor(CronType.QUARTZ);
            CronParser parser = new CronParser(cronDefinition);
            Cron cron = parser.parse(cronExpression);
            cron.validate();

            ExecutionTime executionTime = ExecutionTime.forCron(cron);
            ZoneId zoneId = ZoneId.of(timezone != null ? timezone : defaultTimezone);
            ZonedDateTime now = ZonedDateTime.now(zoneId);

            List<String> nextTimes = new ArrayList<>();
            ZonedDateTime nextExecution = now;

            for (int i = 0; i < count; i++) {
                Optional<ZonedDateTime> next = executionTime.nextExecution(nextExecution);
                if (next.isPresent()) {
                    nextExecution = next.get();
                    nextTimes.add(nextExecution.format(FORMATTER) + " (" + zoneId + ")");
                } else {
                    break;
                }
            }

            return nextTimes;
        } catch (Exception e) {
            throw new IllegalArgumentException("无法计算执行时间: " + e.getMessage());
        }
    }

    private String generateHumanReadable(String cronExpression) {
        String[] parts = cronExpression.trim().split("\\s+");
        
        if (parts.length != 6) {
            return "无法解析的 Cron 表达式";
        }

        String seconds = parts[0];
        String minutes = parts[1];
        String hours = parts[2];
        String dayOfMonth = parts[3];
        String month = parts[4];
        String dayOfWeek = parts[5];

        StringBuilder description = new StringBuilder();

        if ("0".equals(seconds) && "*".equals(minutes) && "*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每分钟执行");
        } else if ("0".equals(seconds) && "0".equals(minutes) && "*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每小时整点执行");
        } else if ("0".equals(seconds) && "0".equals(minutes) && !"*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每天 ").append(String.format("%02d", Integer.parseInt(hours))).append(":00 执行");
        } else if ("0".equals(seconds) && !"*".equals(minutes) && !"*".equals(hours) && "*".equals(dayOfMonth) && "*".equals(month) && "?".equals(dayOfWeek)) {
            description.append("每天 ").append(String.format("%02d:%02d", Integer.parseInt(hours), Integer.parseInt(minutes))).append(" 执行");
        } else {
            description.append("自定义调度: ").append(cronExpression);
        }

        return description.toString();
    }
}
EOF

# 创建控制器类
cat > backend/src/main/java/com/crontools/app/controller/CronController.java << 'EOF'
package com.crontools.app.controller;

import com.crontools.app.model.CronParseResponse;
import com.crontools.app.model.NextTimesResponse;
import com.crontools.app.service.CronService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class CronController {

    @Autowired
    private CronService cronService;

    @Value("${app.default.timezone:Asia/Shanghai}")
    private String defaultTimezone;

    @GetMapping("/parse")
    public ResponseEntity<CronParseResponse> parseCron(
            @RequestParam String expr,
            @RequestParam(defaultValue = "QUARTZ") String type,
            @RequestParam(required = false) String tz) {
        
        try {
            String timezone = tz != null ? tz : defaultTimezone;
            String humanReadable = cronService.parseCronToHuman(expr);
            
            CronParseResponse response = new CronParseResponse(
                expr, type, timezone, humanReadable, true, ""
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            CronParseResponse response = new CronParseResponse(
                expr, type, tz != null ? tz : defaultTimezone, "", false, e.getMessage()
            );
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/next-times")
    public ResponseEntity<NextTimesResponse> getNextTimes(
            @RequestParam String expr,
            @RequestParam(defaultValue = "QUARTZ") String type,
            @RequestParam(required = false) String tz,
            @RequestParam(defaultValue = "5") int count) {
        
        try {
            if (count > 20) count = 20;
            if (count < 1) count = 1;
            
            String timezone = tz != null ? tz : defaultTimezone;
            List<String> nextTimes = cronService.getNextExecutionTimes(expr, timezone, count);
            
            NextTimesResponse response = new NextTimesResponse(nextTimes, true, "");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            NextTimesResponse response = new NextTimesResponse(null, false, e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
EOF

echo "🐳 创建 Docker 配置文件..."

# 创建后端 Dockerfile
cat > backend/Dockerfile << 'EOF'
# Multi-stage build for smaller final image
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN mvn clean package -DskipTests -B

# Runtime stage
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/target/cron-parser-api-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
EOF

# 注意：使用 Maven 官方镜像，不需要 Maven wrapper

echo "🌐 创建前端文件..."

# 创建前端 HTML（简化版，避免过长）
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cron 表达式解析工具</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
        }
        .container {
            background: white; border-radius: 12px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            max-width: 800px; width: 100%;
        }
        h1 { text-align: center; color: #333; margin-bottom: 30px; font-size: 2.5rem; }
        .input-group { display: flex; gap: 10px; margin-bottom: 15px; }
        input[type="text"] {
            flex: 1; padding: 12px; border: 2px solid #e1e1e1; border-radius: 6px;
            font-size: 16px; transition: border-color 0.3s;
        }
        input[type="text"]:focus { outline: none; border-color: #667eea; }
        button {
            padding: 12px 24px; background: #667eea; color: white; border: none;
            border-radius: 6px; font-size: 16px; cursor: pointer; transition: background 0.3s;
        }
        button:hover { background: #5a6fd8; }
        button:disabled { background: #ccc; cursor: not-allowed; }
        .example {
            background: #f8f9fa; padding: 10px; border-radius: 6px; margin-top: 10px;
            font-size: 14px; color: #666;
        }
        .result-card {
            background: #f8f9fa; border-radius: 8px; padding: 20px; margin: 20px 0;
            border-left: 4px solid #667eea;
        }
        .result-title { font-weight: bold; color: #333; margin-bottom: 10px; font-size: 18px; }
        .result-content { color: #555; line-height: 1.6; }
        .error { border-left-color: #e74c3c; background: #fdf2f2; }
        .error .result-title { color: #e74c3c; }
        .next-times { list-style: none; }
        .next-times li { padding: 8px 0; border-bottom: 1px solid #eee; }
        .next-times li:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🕐 Cron 表达式解析工具</h1>
        <div class="input-section">
            <div class="input-group">
                <input type="text" id="cronInput" placeholder="请输入 Cron 表达式，例如: 0 0 4 * * ?" value="0 0 4 * * ?"/>
                <button onclick="parseCron()" id="parseBtn">解析</button>
            </div>
            <div class="example">
                <strong>常用示例：</strong><br>
                • <code>0 0 4 * * ?</code> - 每天凌晨4点<br>
                • <code>0 30 9 ? * MON-FRI</code> - 工作日上午9:30<br>
                • <code>0 0 0/6 * * ?</code> - 每6小时
            </div>
        </div>

        <div class="result-section" id="results" style="display: none;">
            <div class="result-card" id="parseResult">
                <div class="result-title">📋 表达式解释</div>
                <div class="result-content" id="humanReadable"></div>
            </div>
            <div class="result-card" id="timesResult">
                <div class="result-title">⏰ 未来5次执行时间</div>
                <div class="result-content">
                    <ul class="next-times" id="nextTimes"></ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_BASE = '/api';
        
        async function parseCron() {
            const cronExpr = document.getElementById('cronInput').value.trim();
            const parseBtn = document.getElementById('parseBtn');
            const results = document.getElementById('results');
            
            if (!cronExpr) { alert('请输入 Cron 表达式'); return; }

            parseBtn.disabled = true;
            parseBtn.textContent = '解析中...';

            try {
                const parseResponse = await fetch(`${API_BASE}/parse?expr=${encodeURIComponent(cronExpr)}`);
                const parseData = await parseResponse.json();

                if (parseData.valid) {
                    document.getElementById('humanReadable').textContent = parseData.humanReadable;
                    document.getElementById('parseResult').classList.remove('error');

                    const timesResponse = await fetch(`${API_BASE}/next-times?expr=${encodeURIComponent(cronExpr)}&count=5`);
                    const timesData = await timesResponse.json();

                    if (timesData.valid && timesData.nextTimes) {
                        const nextTimesList = document.getElementById('nextTimes');
                        nextTimesList.innerHTML = '';
                        timesData.nextTimes.forEach((time, index) => {
                            const li = document.createElement('li');
                            li.textContent = `${index + 1}. ${time}`;
                            nextTimesList.appendChild(li);
                        });
                        document.getElementById('timesResult').classList.remove('error');
                    } else {
                        showError('timesResult', timesData.message || '无法计算执行时间');
                    }
                } else {
                    showError('parseResult', parseData.message || '无效的 Cron 表达式');
                    document.getElementById('timesResult').style.display = 'none';
                }
                results.style.display = 'block';
            } catch (error) {
                showError('parseResult', '网络错误，请检查后端服务是否运行');
                console.error('Error:', error);
                results.style.display = 'block';
            } finally {
                parseBtn.disabled = false;
                parseBtn.textContent = '解析';
            }
        }

        function showError(elementId, message) {
            const element = document.getElementById(elementId);
            element.classList.add('error');
            if (elementId === 'parseResult') {
                document.getElementById('humanReadable').textContent = message;
            } else {
                document.getElementById('nextTimes').innerHTML = `<li style="color: #e74c3c;">${message}</li>`;
            }
        }

        document.getElementById('cronInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') parseCron();
        });

        window.addEventListener('load', function() { parseCron(); });
    </script>
</body>
</html>
EOF

# 创建前端 Nginx 配置
cat > frontend/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

# 创建前端 Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

# 创建 README
cat > README.md << 'EOF'
# 🕐 Cron 表达式解析工具

## 快速启动

1. 确保已安装 Docker 和 Docker Compose
2. 运行以下命令：

```bash
docker-compose up -d
```

3. 访问：http://YOUR_SERVER_IP

## 项目功能

- ✅ Cron 表达式解析和中文描述
- ✅ 未来执行时间预测
- ✅ 响应式界面设计
- ✅ Docker 容器化部署

## 常用 Cron 示例

- `0 0 4 * * ?` - 每天凌晨4点
- `0 30 9 * * MON-FRI` - 工作日上午9:30
- `0 0 */6 * * ?` - 每6小时

## 故障排除

查看容器日志：
```bash
docker-compose logs -f
```

重启服务：
```bash
docker-compose restart
```
EOF

# 创建 .gitignore
cat > .gitignore << 'EOF'
backend/target/
*.jar
*.war
*.ear
*.zip
*.tar.gz
.idea/
*.iws
*.iml
*.ipr
.vscode/
.DS_Store
Thumbs.db
*.log
.docker/
.env
EOF

echo ""
echo "✅ 项目结构创建完成！"
echo ""
echo "📁 项目位置: $PROJECT_DIR"
echo ""
echo "🚀 下一步："
echo "1. cd $PROJECT_DIR"
echo "2. docker-compose up -d"
echo "3. 访问 http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP')"
echo ""
echo "📝 查看日志: docker-compose logs -f"
echo "🔄 重启服务: docker-compose restart"
echo ""