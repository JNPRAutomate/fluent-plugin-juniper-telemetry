FROM fluent/fluentd:v0.12.24
MAINTAINER Damien Garros <dgarros@gmail.com>

USER root
WORKDIR /home/fluent

## Install python
RUN apk update \
    && apk add python-dev py-pip \
    && pip install --upgrade pip \
    && pip install envtpl

ENV PATH /home/fluent/.gem/ruby/2.2.0/bin:$PATH

RUN apk --no-cache --update add \
                            build-base \
                            ruby-dev && \
    echo 'gem: --no-document' >> /etc/gemrc
RUN gem install --no-ri --no-rdoc \
              statsd-ruby \
              dogstatsd-ruby \
              bigdecimal

RUN apk add gcc

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

COPY    junos-telemetry/compile_protofile.sh compile_protofile.sh

WORKDIR /home/fluent/

USER fluent
EXPOSE 24284

#CMD /home/fluent/fluentd-alpine.start.sh
