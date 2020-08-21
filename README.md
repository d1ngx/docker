# 1.快速启动
```
docker run -d 80:80 kodcloud/kodbox
```
# 2.实现数据持久化——创建数据目录并在启动时挂载
```
mkdir /data
docker run -d -p 80:80 -v /data:/var/www/html kodcloud/kodbox
```
# 3.以https方式启动

-  使用 LetsEncrypt 免费ssl证书
    - 80:80 不能省略
        ```
        docker run -d -p 80:80 -p 443:443  -e DOMAIN="你的域名" -e EMAIL="你的邮箱" --name kodbox kodcloud/kodbox
        ```
    - 生成证书并配置nginx的https
        ```
        docker exec -it kodbox /usr/bin/letsencrypt-setup
        ```
    - 更新证书
        ```
        docker exec -it kodbox /usr/bin/letsencrypt-renew
        ```
-  使用已有ssl证书
    - 证书格式必须是 fullchain.pem  privkey.pem
        ```
        docker run -d -p 443:443  -v "你的证书目录":/etc/nginx/ssl --name kodbox kodcloud/kodbox
        ```

# 4.使用docker-compose同时部署数据库(推荐)
```
version: "3.5"

services:
  db:
    image: mariadb:10.5.5
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    container_name: kodbox_db
    volumes:
      - "./db:/var/lib/mysql"
      - "./mysql-init-files:/docker-entrypoint-initdb.d"
    environment:
      - "TZ"
      - "MYSQL_ALLOW_EMPTY_PASSWORD=yes"
      - "MYSQL_DATABASE"
      - "MYSQL_USER"
      - "MYSQL_PASSWORD"
    restart: always

  app:
    image: kodcloud/kodbox
    container_name: kodbox
    ports:
      - 80:80
      - 443:443
    links:
      - db
      - redis
    volumes:
      - "./data:/var/www/html"
      - "./private-ssl:/etc/nginx/ssl"
    environment:
      - "MYSQL_SERVER"
      - "MYSQL_DATABASE"
      - "MYSQL_USER"
      - "MYSQL_PASSWORD"
      - "REDIS_SERVER"
    restart: always

  redis:
    image: redis:alpine3.12
    container_name: kodbox_redis
    restart: always
```

