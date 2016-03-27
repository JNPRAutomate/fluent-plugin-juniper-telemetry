# fluentd-plugin-juniper-telemetry
Fluentd plugin for Juniper telemetry

## Installation

From gems repository
```
gem install fluent-plugin-juniper-telemetry
```

From source
```
git clone https://github.com/JNPRAutomate/fluent-plugin-juniper-telemetry.git
cd fluent-plugin-juniper-telemetry
rake install
```

## Usage

This plugin include 2 parsers, one for each type of Juniper Devices data streaming type.

**Juniper Telemetry Interface (jvision)**  
Supported devices : MX (up to 15.1F5)
`format juniper_jti`

**analyticsd**  
Supported devices : EX4300 & QFX5100 (add version info)
`format juniper_analyticsd`

> Supported devices are listed as of March 2016, please refer to Juniper website for accurate support list

--------------

## Options

`output_format`: The format of the data send to the output plugin : structured*, statsd, flat

**structured**  

All information are in key/value pair, the list of keys depend of the type of data send.
```
{
    "device":"WFD-QFX5100-48T-1",
    "type":"traffic-stats.txmcpkt",  
    "interface":"xe-0_0_3",  
    "value":838
}
```

> Format "structured" is compatible with output_plugin for influxdb

**flat**
```
{
    "device.wfd-qfx5100-48t-2.interface.xe-0_0_1.queue.latency" : 3231155
}
```

> Format "flat" is compatible with output_plugin for graphite

**Statsd**

```
{
    "statsd_type" : "gauge",
    "statsd_key" : "interface.et-0_0_52.type.txucpkt",
    "statsd_gauge" : 37673515243
}
```

> Format "statsd" is compatible with output_plugin for statsd


### Configuration Example

```
<source>
    @type udp
    tag jnpr.jti
    format juniper_jti
    port 40000
    bind 0.0.0.0
</source>
```

```
<source>
    @type udp
    tag jnpr.analyticsd
    format juniper_analyticsd
    port 40020
    bind 0.0.0.0
</source>
```

Full configuration example is available [here](https://github.com/JNPRAutomate/fluent-plugin-juniper-telemetry/blob/master/fluentd/fluent.conf)  

## Docker container for test & development

The project include a docker container for test and  development.
The container is preconfigured with fluentd for all plugins.  
Configuration file is available [here](https://github.com/JNPRAutomate/fluent-plugin-juniper-telemetry/blob/master/fluentd/fluent.conf)  

By default, everything is going to stdout in /var/log/fluentd.log

You first need to build the container
```
docker build -t fluent-plugin-juniper-telemetry .
```

And then you can launch it
```
docker run --rm -t -i fluent-plugin-juniper-telemetry /sbin/my_init -- bash -l
```

There are 2 scripts provided : **docker.build.sh** and **docker.debug.sh**, to simplify these steps.

### Build ruby library based on proto files

The container has all tools needed to generate ruby library from proto files.  
It's possible to regenerate all ruby files by executing the command below.  

It will mount the project under the directory /gpb inside the container and compile all files
Newly created .rb will be stored under lib/

```
docker run --rm -t -v $(pwd):/gpb -i fluent-plugin-juniper-telemetry /bin/sh /root/compile_protofile.sh
```

## Packet samples for development and troubleshooting

The directory packet_examples include some capture files from different devices.
These can easily be replay and send to another container for development and testing purpose using a [third party container with tcpreplay](https://hub.docker.com/r/dgarros/tcpreplay/)

In order to be able to send these files to any container, we need to change the destition IP and MAc addresses.
In a docker environment, it's possible to use the broadcast address of the internal network 172.17/16 and a generic mac address.  
See instruction below on how to update these information

Replay a capture (while being in the packet_examples directory)
```
docker run --rm -t -v $(pwd):/data -i dgarros/tcpreplay /usr/bin/tcpreplay --intf1=eth0 --pps=100 jvision_phy_int.pcap
```

Rewrite destination Mac and IP addresses
```
docker run --rm -t -v $(pwd):/data -i dgarros/tcpreplay /usr/bin/tcprewrite --infile=jvision_phy_int.pcap --outfile=jvision_phy_int_fixed.pcap --dstipmap=10.92.71.225:172.17.255.255 --enet-dmac=01:00:05:11:00:06 --fixcsum
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
