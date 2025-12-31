# Secured SSHD Container

一个专为高安全性环境设计的 Docker 化 SSH 服务容器。本项目通过强制密钥认证、最小化开放端口、非特权模式运行等多种安全手段，实现攻击面的最小化，为远程访问提供一个安全、隔离的操作环境。

## 🚀 快速开始

### 前置要求
- 系统已安装 https://docs.docker.com/get-docker/ 和 https://docs.docker.com/compose/install/
- 准备用于 SSH 连接的 ED25519 密钥对

### 一键部署
```bash
# 克隆项目
git clone <您的项目仓库地址>
cd secured-sshd-container

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，设置您的 SSH 公钥

# 启动服务
docker-compose up -d
```

### 连接测试
```bash
ssh -i /path/to/your/private/key -p 2222 root@localhost
```

## 📋 目录结构
```
secured-sshd-container/
├── .github/workflows/          # CI/CD 自动化流程
├── docker-compose.yml          # Docker 服务编排定义
├── .env.example                # 环境变量模板
├── Dockerfile                  # 容器镜像构建脚本
├── entrypoint.sh               # 容器启动脚本
└── README.md                   # 项目说明文档
```

## ⚙️ 配置说明

### Docker Compose 配置
```yaml
services:
  secured-sshd:
    image: ghcr.io/WUHINS/secured-sshd-container:latest
    container_name: secured-sshd-server
    ports:
      - "2222:22"  # 宿主机2222端口映射到容器22端口
    environment:
      - SSHD_PERMIT_PASSWORD_LOGIN=no      # 禁用密码登录
      - ROOT_AUTHORIZED_KEYS=${ROOT_AUTHORIZED_KEYS}  # SSH公钥
    volumes:
      - ssh_host_keys:/etc/ssh  # 持久化SSH主机密钥
    security_opt:
      - no-new-privileges:true  # 安全强化
```

### 环境变量 (.env)
| 变量名 | 必需 | 描述 | 示例 |
|--------|------|------|------|
| `ROOT_AUTHORIZED_KEYS` | 是 | SSH公钥内容 | `ssh-ed25519 AAAA...` |
| `SSHD_PERMIT_PASSWORD_LOGIN` | 否 | 是否允许密码登录 | `no` |
| `ROOT_PASSWORD` | 否 | root用户密码 | `YourSecurePassword123!` |

## 🛡️ 安全特性

### 核心安全措施
- **强制密钥认证**：完全禁用密码登录，防止暴力破解
- **非特权运行**：即使使用root用户，权限也被限制在容器内
- **最小端口开放**：仅暴露SSH默认端口22
- **权限控制**：自动设置正确的SSH文件权限

### 安全加固配置
```bash
# 容器安全设置
cap_drop:
  - ALL  # 移除所有非必要内核能力
security_opt:
  - no-new-privileges:true  # 禁止权限提升
```

## 🔧 管理和维护

### 日常操作命令
```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down
```

### 故障排查
1. **连接被拒绝**：检查宿主机防火墙和端口映射
2. **认证失败**：验证SSH密钥权限和authorized_keys文件格式
3. **主机密钥变更**：清理本地known_hosts中旧记录

## 📖 详细文档

### 架构设计
本项目采用最小化设计原则：
- **基础镜像**：Alpine Linux，轻量且安全
- **服务管理**：通过entrypoint.sh脚本动态配置
- **密钥管理**：支持运行时注入SSH公钥

### API参考
#### 环境变量API
- `ROOT_AUTHORIZED_KEYS`：设置授权公钥
- `SSHD_PERMIT_PASSWORD_LOGIN`：控制认证方式
- `ROOT_PASSWORD`：设置root密码（可选）

## 🔄 开发指南

### 构建自定义镜像
```bash
# 构建镜像
docker build -t my-secure-sshd .

# 测试运行
docker run -d -p 2222:22 my-secure-sshd
```

### CI/CD流程
项目包含GitHub Actions工作流，自动完成：
- 多架构镜像构建（linux/amd64, linux/arm64）
- 安全漏洞扫描
- 自动推送至GHCR

## 🚀 快速命令参考

### 一键启动脚本
```bash
#!/bin/bash
# 快速部署脚本
echo "正在启动安全SSH容器..."
docker-compose up -d
echo "服务已启动，使用 ssh -p 2222 root@localhost 连接"
```

### 常用操作
```bash
# 快速重启
docker-compose restart secured-sshd

# 清理重建
docker-compose down && docker-compose up -d

# 查看实时日志
docker-compose logs -f secured-sshd
```

## 📝 使用场景

### 适用场景
- 安全远程访问隔离环境
- 容器化跳板机/网关
- 临时开发调试环境
- 教育演示环境

### 安全建议
1. **定期轮换密钥**：建议每3个月更新一次SSH密钥对
2. **网络隔离**：结合防火墙限制访问源IP
3. **日志监控**：启用系统日志记录和监控
4. **及时更新**：定期更新基础镜像获取安全补丁

## 🙋 常见问题

### Q: 如何重置容器？
```bash
docker-compose down -v  # 清理数据卷
docker-compose up -d    # 重新部署
```

### Q: 如何修改SSH配置？
编辑entrypoint.sh脚本中的sshd_config配置部分，重新构建镜像。

### Q: 支持多用户吗？
当前设计为单root用户，可通过修改entrypoint.sh支持多用户。

---

**注意**：请务必将 `.env` 文件添加到 `.gitignore` 中，避免敏感信息泄露。

## 📄 许可证

本项目采用 Apache 2.0 许可证 - 详见 LICENSE 文件。

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！对于重大更改，请先开 Issue 讨论您想要更改的内容。

---

*最后更新时间：2025年12月31日*
