# 使用Alpine Linux基础镜像，轻量且安全
FROM alpine:latest

# 安装必要的软件包
RUN apk update && apk add --no-cache \
    openssh-server \
    shadow && \
    rm -rf /var/cache/apk/*

# 创建SSH运行目录
RUN mkdir -p /var/run/sshd

# 复制入口点脚本到镜像中
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 设置脚本执行权限
RUN chmod +x /usr/local/bin/entrypoint.sh

# 备份原始sshd_config并创建基本配置
RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 设置入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 设置默认命令为启动SSHD服务
CMD ["/usr/sbin/sshd", "-D", "-e"]

# 声明容器暴露的端口
EXPOSE 22
