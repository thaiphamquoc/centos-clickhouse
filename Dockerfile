FROM thaiphamquoc/centos-gcc-6:1.0.0
MAINTAINER tpham

USER root

ARG clickhouse_version="v1.1.54318-stable"
ARG threads=4
ARG work_dir=/tmp/clickhouse

WORKDIR ${work_dir}

RUN yum -y install libicu-devel readline-devel openssl-devel unixODBC-devel libtool-ltdl-devel
RUN wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm && \
    yum -y --nogpgcheck install mysql57-community-release-el7-9.noarch.rpm && \
    rm -rf mysql57-community-release-el7-9.noarch.rpm
RUN yum -y install mysql-community-devel
RUN ln -s /usr/lib64/mysql/libmysqlclient.a /usr/lib64/libmysqlclient.a

COPY cmake.repo /etc/yum.repos.d/cmake.repo
RUN yum -y install epel-release
RUN yum -y install cmake3

RUN git clone -b ${clickhouse_version} https://github.com/yandex/ClickHouse.git && \
    cd ClickHouse && git submodule update --init --recursive

WORKDIR ${work_dir}/ClickHouse/build
RUN cmake3 ..; exit 0
RUN cmake3 .. && make -j $threads && make install && \
    rm -rf ${work_dir}

WORKDIR /

ENV CLICKHOUSE_CONFIG=/etc/clickhouse-server/config.xml

ENTRYPOINT exec clickhouse-server --config=${CLICKHOUSE_CONFIG}
