

build:
	docker build -t fluent-plugin-juniper-telemetry .

debug:
	docker stop fluent-plugin-juniper-telemetry_con
	docker rm fluent-plugin-juniper-telemetry_con
	docker run --rm -t \
	    -p 40000:40000/udp -p 40001:40001/udp \
	    -p 40010:40010/udp -p 40011:40011/udp -p 40012:40012/udp \
	    -p 40020:40020/udp -p 40021:40021/udp -p 40022:40022/udp \
	    --volume $(shell pwd):/home/fluent/fluentd-plugin-juniper-telemetry \
	    --name fluent-plugin-juniper-telemetry_con \
	    -i fluent-plugin-juniper-telemetry

gems-build:
	docker run -i -t \
	    --volume $(shell pwd):/home/fluent/fluentd-plugin-juniper-telemetry \
			-w /home/fluent/fluentd-plugin-juniper-telemetry \
	    fluent-plugin-juniper-telemetry gem build fluent-plugin-juniper-telemetry.gemspec

			# gem build fluentd-plugin-juniper-telemetry/fluent-plugin-juniper-telemetry.gemspec

gems-push:
	docker run -i -t \
	    --volume $(shell pwd):/home/fluent/fluentd-plugin-juniper-telemetry \
			-w /home/fluent/fluentd-plugin-juniper-telemetry \
	    fluent-plugin-juniper-telemetry gem push fluent-plugin-juniper-telemetry-*.gem

			# gem build fluentd-plugin-juniper-telemetry/fluent-plugin-juniper-telemetry.gemspec
