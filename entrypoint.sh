#!/bin/sh
set -e  # 遇到错误立即退出，增加健壮性

# 1. 为 root 用户配置 SSH 密钥
# 如果环境变量 ROOT_AUTHORIZED_KEYS 已被设置，则使用它来配置密钥认证
if [ -n "$ROOT_AUTHORIZED_KEYS" ]; then
  mkdir -p /root/.ssh
  echo "$ROOT_AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
  echo "✅ 公钥已成功配置。"
fi

# 2. 生成 SSH 主机密钥（如果不存在）
# 特别是使用您指定的 Ed25519 密钥
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
  echo "✅ SSH 主机 Ed25519 密钥已生成。"
fi

# 3. (可选) 根据环境变量动态配置 sshd_config
# 例如，是否允许密码登录（强烈建议设置为 no）
if [ "$SSHD_PERMIT_PASSWORD_LOGIN" = "yes" ]; then
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
fi
# 确保禁止 root 用户的密码登录，仅允许密钥认证
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

echo "🚀 启动 SSHD 服务..."
# 4. 使用 exec 执行 CMD，确保 SSHD 成为 PID 1 并接收信号
exec "$@"
