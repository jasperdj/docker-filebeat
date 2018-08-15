FROM library/alpine:3.5

ENV FILEBEAT_VERSION=6.3.1 \
    GLIBC_VERSION=2.25-r0

# Install glibc
RUN apk --no-cache add ca-certificates wget \
	&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
	&& apk add glibc-2.28-r0.apk

# Install filebeat
RUN wget -q -O /tmp/filebeat.tar.gz https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz \
    && cd /tmp \
    && tar xzvf filebeat.tar.gz \
    && cd filebeat-* \
    && cp filebeat /bin \
    && mkdir -p /etc/filebeat \
    && cp filebeat.yml /etc/filebeat/filebeat.example.yml \
    && rm -rf /tmp/filebeat*

RUN chmod -R 777 /etc/filebeat/	
RUN chown root /etc/filebeat/
	
HEALTHCHECK --interval=5s --timeout=3s \
    CMD ps aux | grep '[f]ilebeat' || exit 1

CMD [ "filebeat", "-e", "-c", "/etc/filebeat/filebeat.yml"]
