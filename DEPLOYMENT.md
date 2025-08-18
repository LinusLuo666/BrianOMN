# 🚀 服务器部署指南

## 快速部署（全新服务器）

### 第一步：配置服务器环境
```bash
# SSH 连接到服务器
ssh ubuntu@YOUR_SERVER_IP

# 下载并运行环境配置脚本
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/BrianOMN/master/deploy-script.sh
chmod +x deploy-script.sh
./deploy-script.sh

# ⚠️ 重要：重新登录以应用 Docker 权限
exit
ssh ubuntu@YOUR_SERVER_IP
```

### 第二步：创建项目并启动
```bash
# 下载并运行项目生成脚本
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/BrianOMN/master/quick-deploy.sh
chmod +x quick-deploy.sh
./quick-deploy.sh

# 启动服务
cd ~/cron-tools
docker-compose up -d

# 查看启动状态
docker-compose ps
docker-compose logs -f
```

### 第三步：访问应用
```bash
# 获取服务器 IP
curl ifconfig.me

# 浏览器访问
http://YOUR_SERVER_IP
```

## 🔧 脚本说明

| 脚本 | 作用 | 运行时机 |
|------|------|----------|
| `deploy-script.sh` | 配置服务器环境<br>• 安装 Docker/Docker Compose<br>• 配置防火墙<br>• 设置用户权限 | 全新服务器首次配置 |
| `quick-deploy.sh` | 生成项目代码<br>• 创建完整项目结构<br>• 生成所有源代码<br>• 配置 Docker 文件 | 环境配置完成后 |

## 📋 部署检查清单

### 环境配置阶段
- [ ] 服务器可 SSH 连接
- [ ] `deploy-script.sh` 执行成功
- [ ] 重新登录应用 Docker 权限
- [ ] `docker --version` 命令正常

### 项目部署阶段  
- [ ] `quick-deploy.sh` 执行成功
- [ ] `~/cron-tools` 目录创建完成
- [ ] `docker-compose up -d` 启动成功
- [ ] 容器状态为 `running`

### 功能验证阶段
- [ ] 前端页面可访问
- [ ] API 健康检查通过：`curl http://YOUR_SERVER_IP/api/health`
- [ ] Cron 解析功能正常

## 🚨 常见问题

### 问题1：权限不足
```bash
# 症状：docker 命令需要 sudo
# 解决：确保重新登录 SSH 会话
exit
ssh ubuntu@YOUR_SERVER_IP
```

### 问题2：端口占用
```bash
# 检查端口占用
sudo netstat -tlnp | grep :80

# 修改端口（编辑 docker-compose.yml）
ports:
  - "8080:80"  # 改为 8080 端口
```

### 问题3：容器启动失败
```bash
# 查看详细日志
docker-compose logs backend
docker-compose logs frontend

# 重新构建
docker-compose down
docker-compose up -d --build
```

### 问题4：网络无法访问
```bash
# 检查防火墙状态
sudo ufw status

# 手动开放端口
sudo ufw allow 80/tcp
```

## 🔄 维护命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 更新项目
git pull
docker-compose up -d --build

# 备份数据（如果有的话）
docker-compose down
tar -czf backup-$(date +%Y%m%d).tar.gz ~/cron-tools

# 完全清理
docker-compose down
docker system prune -a
```

## 📱 访问测试

部署完成后，在浏览器中访问：
- **主页面**：`http://YOUR_SERVER_IP`
- **健康检查**：`http://YOUR_SERVER_IP/api/health`

测试输入：`0 0 4 * * ?`  
预期输出：`每天 04:00 执行` + 未来5次执行时间

---

## 🌍 生产环境优化（可选）

### 配置域名
```bash
# 1. 将域名 A 记录指向服务器 IP
# 2. 安装 Let's Encrypt
sudo apt install snapd
sudo snap install --classic certbot

# 3. 申请 SSL 证书
sudo certbot --nginx -d yourdomain.com

# 4. 设置自动续期
sudo crontab -e
# 添加: 0 12 * * * /usr/bin/certbot renew --quiet
```

### 性能监控
```bash
# 安装监控工具
sudo apt install htop iotop

# 查看资源使用
htop
docker stats
```

**部署完成！🎉 享受您的 Cron 表达式解析工具！**