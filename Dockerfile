FROM thaiphamquoc/centos-gcc-6:1.0.0
MAINTAINER tpham

USER root

ARG clickhouse_version="v1.1.54318-stable"
ARG threads=4
ARG work_dir=/tmp/clickhouse

WORKDIR ${work_dir}

COPY cmake.repo /etc/yum.repos.d/cmake.repo

RUN yum -y install libicu-devel readline-devel openssl-devel unixODBC-devel libtool-ltdl-devel && \
    yum -y install openssl && \
    wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm && \
    yum -y --nogpgcheck install mysql57-community-release-el7-9.noarch.rpm && \
    rm -rf mysql57-community-release-el7-9.noarch.rpm && \
    yum -y install mysql-community-devel && \
    ln -s /usr/lib64/mysql/libmysqlclient.a /usr/lib64/libmysqlclient.a && \
    yum -y install epel-release && \
    yum -y install cmake3 && \
    git clone -b ${clickhouse_version} https://github.com/yandex/ClickHouse.git && \
    cd ClickHouse && git submodule update --init --recursive && \
    mkdir build && cd build && cmake3 .. || true && cmake3 .. && make -j ${threads} && make install && \
    rm -rf ${work_dir}

WORKDIR /

COPY etc/clickhouse-server/config.xml /etc/clickhouse-server/config.xml
COPY etc/clickhouse-server/users.xml /etc/clickhouse-server/users.xml
ENV CLICKHOUSE_CONFIG=/etc/clickhouse-server/config.xml

ENTRYPOINT exec clickhouse-server --config=${CLICKHOUSE_CONFIG}
