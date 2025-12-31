FROM alpine:latest

RUN apk update && apk add --no-cache openssh-server && \
    ssh-keygen -A && mkdir -p /var/run/sshd

# 将入口点脚本复制到镜像中
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置入口点，并定义默认命令为启动 SSHD
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
