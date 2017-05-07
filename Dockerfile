FROM ubuntu:16.04

RUN groupadd -r monero && useradd -r -m -g monero monero

ENV XMR_STAK_CPU_VERSION v1.2.0-1.4.1
ENV XMR_STAK_CPU_URL https://github.com/fireice-uk/xmr-stak-cpu.git

# IF SETTING DONATE TO 0 please consider a one time donation to the developer wallet (From donate-level.h)
# 4581HhZkQHgZrZjKeCfCJxZff9E3xCgHGF25zABZz7oR71TnbbgiS7sK9jveE6Dx6uMs2LwszDuvQJgRZQotdpHt1fTdDhk  
ENV DONATE_LEVEL 0.0

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates wget git libmicrohttpd-dev libssl-dev cmake build-essential \
	&& rm -rf /var/lib/apt/lists/* && apt-get -y clean && apt-get -y autoclean && apt-get -y autoremove \

	# grab gosu for easy step-down from root
	&& gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& wget -qO /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
	&& wget -qO /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

WORKDIR /tmp
RUN set -ex \
	&& git clone $XMR_STAK_CPU_URL \
	&& cd xmr-stak-cpu \
	&& sed -i -e "s/1\.0/$DONATE_LEVEL/" donate-level.h && grep DonationLevel donate-level.h \
	&& cmake . \
	&& make install \
	&& cp /tmp/xmr-stak-cpu/bin/xmr-stak-cpu /usr/bin \
	&& cd /tmp && rm -rf xmr-stak-cpu

RUN set -ex \
	# remove build dependencies
	&& apt-get purge -y --auto-remove wget git

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

