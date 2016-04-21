FROM phusion/baseimage:0.9.18
MAINTAINER Damien Garros <dgarros@gmail.com>

RUN     apt-get -y update && \
        apt-get -y upgrade

# dependencies
RUN     apt-get -y --force-yes install \
        git adduser libfontconfig wget ruby ruby-dev make curl \
        build-essential tcpdump libprotobuf-dev protobuf-compiler

## Enable SSH
RUN     rm -f /etc/service/sshd/down
RUN     /usr/sbin/enable_insecure_key

#####################################
### Install google protocol buffer ##
#####################################

RUN     gem install protobuf && \
        mkdir /gpb

ADD     junos-telemetry/compile_protofile.sh /root/compile_protofile.sh
RUN     chmod +x /root/compile_protofile.sh

########################
### Install Fluentd  ###
########################

RUN     gem install fluentd rake bundler --no-ri --no-rdoc
RUN     gem install fluent-plugin-file-sprintf

ADD     fluentd/fluent.conf /fluent/fluent.conf
RUN     fluentd --setup ./fluent

ADD     fluentd/fluentd.launcher.sh /etc/service/fluentd/run
RUN     chmod +x /etc/service/fluentd/run

ADD     fluentd/showlog.sh /root/showlog.sh
RUN     chmod +x /root/showlog.sh

######################################################
### Create directory to mount local file           ###
######################################################

RUN     mkdir /root/fluentd-plugin-juniper-telemetry
ENV     RUBYLIB   /root/fluentd-plugin-juniper-telemetry/lib

WORKDIR "/root"

# WORKDIR "/root/fluentd-plugin-juniper-telemetry"
#
# ADD     lib /root/fluentd-plugin-juniper-telemetry/lib
# ADD     junos-telemetry /root/fluentd-plugin-juniper-telemetry/junos-telemetry
#
# ADD     Gemfile Gemfile
# ADD     Rakefile Rakefile
# ADD     fluent-plugin-juniper-telemetry.gemspec fluent-plugin-juniper-telemetry.gemspec
#
# RUN     rake install

RUN     apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME /root
RUN chmod -R 777 /var/log/

CMD ["/sbin/my_init"]
