#! /bin/bash

docker stop fluent-plugin-juniper-telemetry_con
docker rm fluent-plugin-juniper-telemetry_con

docker run --rm -t \
    -p 40000:40000/udp -p 40001:40001/udp \
    -p 40010:40010/udp -p 40011:40011/udp -p 40012:40012/udp \
    -p 40020:40020/udp -p 40021:40021/udp -p 40022:40022/udp \
    --name fluent-plugin-juniper-telemetry_con \
    -i fluent-plugin-juniper-telemetry /sbin/my_init -- bash -l
