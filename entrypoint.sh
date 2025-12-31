#!/bin/sh
set -e  # 遇到错误立即退出，增加健壮性

# 1. 设置root用户密码（如果环境变量ROOT_PASSWORD已设置）
if [ -n "$ROOT_PASSWORD" ]; then
  echo "root:$ROOT_PASSWORD" | chpasswd
  echo "✅ Root用户密码已设置。"
else
  echo "⚠️  未设置ROOT_PASSWORD环境变量，使用默认密码或密钥认证。"
fi

# 2. 为root用户配置SSH密钥（如果环境变量ROOT_AUTHORIZED_KEYS已设置）
if [ -n "$ROOT_AUTHORIZED_KEYS" ]; then
  mkdir -p /root/.ssh
  echo "$ROOT_AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
  echo "✅ SSH公钥已成功配置。"
fi

# 3. 生成SSH主机密钥（如果不存在）
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
  echo "✅ SSH主机Ed25519密钥已生成。"
fi

# 4. 动态配置sshd_config
# 根据环境变量决定是否允许密码登录
if [ "$SSHD_PERMIT_PASSWORD_LOGIN" = "yes" ]; then
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  echo "✅ 已启用密码认证。"
else
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  echo "✅ 已禁用密码认证，仅允许密钥登录。"
fi

# 配置root登录方式
if [ -n "$ROOT_AUTHORIZED_KEYS" ]; then
  # 如果设置了公钥，则禁止密码登录root
  sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  echo "✅ 已设置Root用户仅允许密钥登录。"
else
  # 如果没有设置公钥，但允许密码登录，则允许root密码登录
  if [ "$SSHD_PERMIT_PASSWORD_LOGIN" = "yes" ]; then
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "✅ 已设置Root用户允许密码登录。"
  else
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    echo "✅ 已完全禁用Root用户登录。"
  fi
fi

echo "🚀 启动SSHD服务..."
# 5. 使用exec执行CMD，确保SSHD成为PID 1并正确接收信号
exec "$@"
