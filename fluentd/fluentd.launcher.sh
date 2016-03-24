#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
# fluentd -c /fluent/fluent.conf -vv
fluentd -c /root/fluentd-plugin-juniper-telemetry/fluentd/fluent.conf \
        -v \
        -p /root/fluentd-plugin-juniper-telemetry/lib/fluent/plugin \
        >> /var/log/fluentd.log 2>&1
