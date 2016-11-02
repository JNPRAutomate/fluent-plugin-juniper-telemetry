FROM fluent/fluentd:v0.12.29
MAINTAINER Damien Garros <dgarros@gmail.com>

USER root
WORKDIR /home/fluent

## Install python
RUN apk update \
    && apk add python-dev py-pip \
    && pip install --upgrade pip \
    && pip install envtpl
    # && apk del -r --purge gcc make g++ \
    # && rm -rf /var/cache/apk/*

ENV PATH /home/fluent/.gem/ruby/2.2.0/bin:$PATH

RUN apk --no-cache --update add \
                            build-base \
                            ruby-dev && \
    echo 'gem: --no-document' >> /etc/gemrc
RUN gem install --no-ri --no-rdoc \
              statsd-ruby \
              dogstatsd-ruby \
              bigdecimal
    # apk del build-base ruby-dev && \
    # rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN apk add gcc

RUN apk update &&\
    apk add ca-certificates &&\
    update-ca-certificates &&\
    apk add openssl

# RUN     cd /tmp && \
#         wget https://github.com/google/protobuf/releases/download/v3.0.0-beta-3/protobuf-cpp-3.0.0-beta-3.tar.gz&&\
#         tar -xzf protobuf-cpp-3.0.0-beta-3.tar.gz &&\
#         cd protobuf-3.0.0-beta-3 &&\
#         ./configure --prefix=/usr &&\
#         make &&\
#         make install
#
RUN     cd /tmp && \
        wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz &&\
        tar -xzf protobuf-2.6.1.tar.gz &&\
        cd protobuf-2.6.1 &&\
        ./configure --prefix=/usr &&\
        make &&\
        make install

WORKDIR /home/fluent/
RUN     mkdir fluentd-plugin-juniper-telemetry
ADD     fluentd/fluentd.launcher.sh fluentd.sh
RUN     chmod +x fluentd.sh
ENV     RUBYLIB   /home/fluent/fluentd-plugin-juniper-telemetry/lib

RUN     gem install --prerelease protobuf
# RUN     gem install --prerelease google-protobuf

COPY    junos-telemetry/compile_protofile.sh compile_protofile.sh

USER fluent
# RUN    export PATH="/home/fluent:$PATH"
# RUN     wget https://github.com/google/protobuf/releases/download/v3.0.0-beta-3/protoc-3.0.0-beta-3-linux-x86_32.zip
# RUN     unzip protoc-3.0.0-beta-3-linux-x86_32.zip

WORKDIR /home/fluent/
# Copy Start script to generate configuration dynamically
#ADD     fluentd-alpine.start.sh         fluentd-alpine.start.sh
#RUN     chown -R fluent:fluent fluentd-alpine.start.sh
#RUN     chmod 777 fluentd-alpine.start.sh

USER fluent
EXPOSE 24284

CMD fluentd -c /home/fluent/fluentd-plugin-juniper-telemetry/fluentd/fluent.conf \
        -v \
        -p /home/fluent/fluentd-plugin-juniper-telemetry/lib/fluent/plugin
