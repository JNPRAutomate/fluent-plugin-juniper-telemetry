#!/bin/sh
/usr/bin/protoc -I /gpb/junos-telemetry --ruby_out /gpb/lib /gpb/junos-telemetry/*.proto
