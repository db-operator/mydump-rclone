FROM mariadb:12

RUN apt-get update && apt-get install -y \
        curl \
        bash \
        rclone

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

WORKDIR /backup
ENTRYPOINT /entrypoint.sh
