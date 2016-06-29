#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
# fluentd -c /fluent/fluent.conf -vv
fluentd -c //home/fluent/fluentd-plugin-juniper-telemetry/fluent.conf \
        -vvv \
        -p //home/fluent/fluentd-plugin-juniper-telemetry/lib/fluent/plugin
