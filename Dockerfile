ARG RUBY_PATH=/usr/local
ARG RUBY_VERSION=2.6.10
ARG RUBY_CONFIGURE_OPTS=--with-jemalloc

FROM rockylinux:9 AS rubybuild
ARG RUBY_PATH
ARG RUBY_VERSION
ARG RUBY_CONFIGURE_OPTS
RUN yum -y install git autoconf gcc make zlib-devel
RUN git clone https://github.com/jemalloc/jemalloc.git
RUN cd jemalloc/ && ./autogen.sh && ./configure && make && make install && cd ../ && rm -rf jemalloc/
RUN git clone https://github.com/rbenv/ruby-build.git $RUBY_PATH/plugins/ruby-build \
&&  $RUBY_PATH/plugins/ruby-build/install.sh
RUN yum -y install \
         openssl-devel
RUN LD_LIBRARY_PATH=/usr/local/lib RUBY_CONFIGURE_OPTS=$RUBY_CONFIGURE_OPTS ruby-build $RUBY_VERSION $RUBY_PATH

FROM rockylinux:9
ARG RUBY_PATH
ENV PATH $RUBY_PATH/bin:$PATH
RUN yum -y install \
        epel-release 
RUN yum -y install \
        autoconf \
        make \
        gcc \
        git \
        openssl-devel \
        zlib-devel \
        mysql \
        redis \
        sqlite-devel \
        bzip2

RUN git clone https://github.com/jemalloc/jemalloc.git
RUN cd jemalloc/ && ./autogen.sh && ./configure && make && make install && cd ../ && rm -rf jemalloc/

COPY --from=rubybuild $RUBY_PATH $RUBY_PATH

RUN gem update --system
CMD [ "irb" ]