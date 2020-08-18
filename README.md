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

-  使用 letsencrypt 免费ssl证书
```
docker run -d -p 80:80 -p 443:443  -e DOMAIN="你的域名" -e EMAIL="你的邮箱"  --name kodbox kodcloud/kodbox
# 生成证书并配置nginx的https
docker exec -it kodbox /usr/bin/letsencrypt-setup
# 更新证书
docker exec -it kodbox /usr/bin/letsencrypt-renew
```
-  使用已有ssl证书
```
# 证书格式必须是 fullchain.pem  privkey.pem
docker run -d -p 80:80 -p 443:443  -v "你的证书目录":/etc/nginx/ssl --name kodbox kodcloud/kodbox
```
