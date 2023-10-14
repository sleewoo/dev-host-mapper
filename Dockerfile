
FROM alpine:3.18

RUN apk update && apk upgrade && apk add --no-cache \
  dnsmasq=~2.89 \
  nginx=~1.24 \
  s6=~2.11 \
  bash=~5.2 \
;

RUN rm -fr \
  /etc/dnsmasq* \
  /etc/nginx* \
  /etc/vhosts* \
;

COPY /rootfs /

ENTRYPOINT [ "/bootstrap" ]

