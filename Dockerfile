FROM centos:7

RUN curl http://download.rethinkdb.com/centos/7/`uname -m`/rethinkdb.repo -o /etc/yum.repos.d/rethinkdb.repo \
		&& yum update -y \
		&& yum install -y \
			curl \
			unzip \
			which \
			rethinkdb \
		&& yum clean all

# Install Consul
# Releases at https://releases.hashicorp.com/consul
# Add Consul and set its configuration
RUN export CONSUL_VER=0.9.2 \
    && export CONSUL_PKG=consul_${CONSUL_VER}_linux_amd64.zip \
    && export CONSUL_URL=https://releases.hashicorp.com/consul/${CONSUL_VER}/${CONSUL_PKG} \
    && export CONSUL_SHA256=$(curl https://releases.hashicorp.com/consul/0.9.2/consul_${CONSUL_VER}_SHA256SUMS | grep ${CONSUL_PKG} | awk '{print $1}') \
    && curl -Ls --fail -o /tmp/${CONSUL_PKG} ${CONSUL_URL} \
    && echo "${CONSUL_SHA256} /tmp/${CONSUL_PKG}" | sha256sum -c \
    && unzip /tmp/${CONSUL_PKG} -d /usr/local/bin \
    && rm /tmp/${CONSUL_PKG} \
    && mkdir /etc/consul \
    && mkdir /var/lib/consul \
    && mkdir /data \
    && mkdir /config

# Install Consul template
# Releases at https://releases.hashicorp.com/consul-template/
RUN export CT_VER=0.19.0 \
    && export CT_PKG=consul-template_${CT_VER}_linux_amd64.zip \
    && export CT_URL=https://releases.hashicorp.com/consul-template/${CT_VER}/${CT_PKG} \
    && export CT_SHA256=$(curl -Ls --fail https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_SHA256SUMS | grep ${CT_PKG} | awk '{print $1}') \
    && curl -Ls --fail -o /tmp/${CT_PKG} ${CT_URL} \
    && echo "${CT_SHA256} /tmp/${CT_PKG}" | sha256sum -c \
    && unzip /tmp/${CT_PKG} -d /usr/local/bin \
    && rm /tmp/${CT_PKG}

# Add Containerpilot and set its configuration
ENV CONTAINERPILOT=/etc/containerpilot.json5
RUN export CP_VER=3.4.0 \
    && export CP_PKG=containerpilot-${CP_VER}.tar.gz \
    && export CP_SHA1=$(curl -Ls --fail https://github.com/joyent/containerpilot/releases/download/${CP_VER}/containerpilot-${CP_VER}.sha1.txt | awk '{print $1}') \
    && export CP_URL=https://github.com/joyent/containerpilot/releases/download/${CP_VER}/${CP_PKG} \
    && curl -Ls --fail -o /tmp/${CP_PKG} ${CP_URL} \
    && echo "${CP_SHA1} /tmp/${CP_PKG}" | sha1sum -c \
    && tar zxf /tmp/${CP_PKG} -C /usr/local/bin \
    && rm /tmp/${CP_PKG}

# ref https://www.rethinkdb.com/docs/config-file/
# Add Configs and Binaries
COPY etc/containerpilot.json5 /etc
COPY etc/rethinkdb.conf.ctmpl /etc
COPY bin /bin

EXPOSE 28015 29015 8080
