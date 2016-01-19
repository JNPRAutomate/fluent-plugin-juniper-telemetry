# fluentd-plugin-juniper-telemetry
Fluentd plugin for Juniper telemetry

## Installation

From gems repository (once available)
```
= Not yet available =
fluent-gem install fluent-plugin-juniper-telemetry
```

From source
```
git clone https://github.com/JNPRAutomate/fluent-plugin-juniper-telemetry.git
cd fluent-plugin-juniper-telemetry
rake install
```

## Usage

This plugin include 3 parsers, one for each type of Juniper Devics data streaming type.


jvision:
Supported devices : MX (add version info)
`format juniper_jvision`

analyticsd:
Supported devices : EX4300 & QFX5100 (add version info)
`format juniper_analyticsd`


network agent:
Supported devices :  
`format juniper_na`

> Supported devices are listed as of Jan 2016, please refer to Juniper website for accurate support list

--------------

## Options

`output_format`: The format of the date send to the output plugin : structured*, statsd, flat

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

**flat**
```
```

**Statsd**

```
```

### Configuration Example

```
<source>
    @type udp
    tag jnpr.statsd
    format juniper_analyticsd
    output_format statsd
    port 51020
    bind 0.0.0.0
</source>
```

```
<source>
    @type udp
    tag jnpr.statsd
    format juniper_analyticsd
    port 51020
    bind 0.0.0.0
</source>
```

```
<source>
    @type udp
    tag jnpr.statsd
    format juniper_na
    output_format flat
    port 51020
    bind 0.0.0.0
</source>
```

## Build ruby library based on proto files

The container has all tools needed to generate ruby library from proto files.  
It's possible to regenerate all ruby files by executing the command below.  

It will mount the project under the directory /gpb inside the container and compile all files
Newly created /rb will be stored under lib/

```
docker run --rm -t -v $(pwd):/gpb -i fluent-plugin-juniper-telemetry /bin/sh /root/compile_protofile.sh
```

## Packet samples for development and troubleshooting

The directory packet_examples include some capture files from different devices.
These can easily be replay and send to another container for development and testing purpose using a [third party container with tcpreplay](https://hub.docker.com/r/dgarros/tcpreplay/)

In order to be able to send these files to any container, we need to change the destition IP and MAc addresses.
In a docker environment, it's possible to use the broadcast address of the internal network 172.17/16 and a generic mac address.  
See instruction below on how to update these information

Replay a capture (while beeing in the packet_examples directory)
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