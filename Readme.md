
# Nginx with Certbot

### Using

#### Default
add to your .bashrc for set variable local ip
```shell
export HostIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -n 1)
```

And run docker-compose.yml
```shell
docker-compose up -d
```

#### For simple ssl

```shell
docker exec -it 2af9fc39f387 certbot --nginx -d plataforma.xpag.com.br
```
_Change 2af9fc39f387 for your container id_

#### For wildcard

```shell
docker exec -it 2af9fc39f387 certbot --dns-cloudflare --dns-cloudflare-credentials /etc/secrets/cloudflare.ini certonly --dns-cloudflare-propagation-seconds 70 -d *.example.com -d example.com
```
_Change 2af9fc39f387 for your container id_

### Templates

### docker-compose.yml


```yaml
version: '3'

services:
    nginx:
          image: devesharp/nginx-certbot:latest
          volumes:
            - ./conf.d:/etc/nginx/conf.d
            - ./certs:/etc/nginx/certs
            - ./letsencrypt:/etc/letsencrypt
          extra_hosts:
            host: $HostIP
          restart: always
          ports:
            - 80:80
            - 443:443
```

#### default.conf

```ini
server {
    server_name example.com.br;

	gzip on;
	gzip_vary on;
	gzip_min_length 10240;
	gzip_proxied expired no-cache no-store private auth;
	gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
	gzip_disable "MSIE [1-6]\.";

    location / {
        add_header ServerHostname $hostname;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_pass_header Server;
        proxy_redirect off;

        proxy_pass http://host:8081; # Python server running in container with port 8081 inside your host
    }

    listen 80;
}
```

#### wildcard.conf

```ini
server {
    server_name  *.example.com;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    # redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    listen [::]:443 ssl ipv6only=on;
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
}

server {
    return 301 https://$host$request_uri;

    listen       80;
    listen  [::]:80;
    server_name  *.devesharp.com;
    return 404;
}
```
