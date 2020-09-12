# 1.快速启动
```
docker run -d -p 80:80 kodcloud/kodbox:v1.12
```
# 2.实现数据持久化——创建数据目录并在启动时挂载
```
mkdir /data
docker run -d -p 80:80 -v /data:/var/www/html kodcloud/kodbox:v1.12
```
# 3.以https方式启动

-  使用 LetsEncrypt 免费ssl证书
    - 80:80 不能省略
        ```
        docker run -d -p 80:80 -p 443:443  -e DOMAIN="你的域名" -e EMAIL="你的邮箱" --name kodbox kodcloud/kodbox:v1.12
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
        docker run -d -p 443:443  -v "你的证书目录":/etc/nginx/ssl --name kodbox kodcloud/kodbox:v1.12
        ```

# 4.[使用docker-compose同时部署数据库（推荐）](https://github.com/ericdoomed/docker/tree/master/nginx-fpm/compose)
```
git clone https://github.com/ericdoomed/docker.git kodbox
cd ./kodbox/nginx-fpm/compose/
docker-compose up -d
```
- 把环境变量都写在.env文件中
- 如果修改.env中数据库名称(MYSQL_DATABASE)，需要同时修改./mysql-init-files/kodbox.sql 首行“use 数据库名称”

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
# 5.[使用fpm版本+单独nginx镜像](https://github.com/ericdoomed/docker/tree/master/fpm-alpine/compose)
```
git clone https://github.com/ericdoomed/docker.git kodbox
cd ./kodbox/fpm-alpine/compose/
docker-compose up -d
```
```
version: '3.5'

services:
  db:
    image: mariadb:10.5.5
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
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
    image: kodcloud/kodbox:v1.12-fpm-alpine
    volumes:
      - "./data:/var/www/html"
    environment:
      - "MYSQL_SERVER"
      - "MYSQL_DATABASE"
      - "MYSQL_USER"
      - "MYSQL_PASSWORD"
      - "REDIS_HOST"
    restart: always

  web:
    image: nginx:1.19.2
    ports:
      - 80:80
    links:
      - db
      - redis
    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"
      - "./data:/var/www/html:ro"
    depends_on:
      - app
    restart: always
    
  redis:
    image: redis:alpine3.12
    restart: always
```
