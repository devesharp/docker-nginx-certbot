
FROM nginx:alpine

RUN apk add --no-cache python3 python3-dev py3-pip build-base libressl-dev musl-dev libffi-dev

RUN pip3 install --break-system-packages --upgrade pip
RUN pip3 install --break-system-packages certbot-nginx
RUN pip3 install --break-system-packages certbot-dns-cloudflare

RUN mkdir -p /etc/letsencrypt
