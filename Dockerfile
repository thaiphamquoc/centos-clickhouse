FROM thaiphamquoc/centos-gcc-6:1.0.0
MAINTAINER tpham

USER root

ENV CLICKHOUSE_VERSION="v1.1.54318-stable" \
    THREADS=4 \
    WORK_DIR=/tmp/clickhouse

# install cmake3
COPY cmake.repo /etc/yum.repos.d/cmake.repo
RUN yum -y upgrade && \
    yum -y install epel-release openssl-devel cmake3

WORKDIR ${WORK_DIR}

# install clickhouse dependencies
RUN wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm && \
    yum -y --nogpgcheck install mysql57-community-release-el7-9.noarch.rpm && \
    yum -y install mysql-community-devel

RUN ln -s /usr/lib64/mysql/libmysqlclient.a /usr/lib64/libmysqlclient.a

RUN git clone -b ${CLICKHOUSE_VERSION} https://github.com/yandex/ClickHouse.git

WORKDIR ${WORK_DIR}/ClickHouse
RUN git submodule update --init --recursive
RUN mkdir build

WORKDIR ${WORK_DIR}/ClickHouse/build
RUN cmake3 ..
RUN make -j $THREADS && make install

ENV CLICKHOUSE_CONFIG=/etc/clickhouse-server/config.xml

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# clean up
RUN yum clean all
RUN rm -rf ${WORK_DIR}
