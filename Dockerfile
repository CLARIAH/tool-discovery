#Harvester + Store run in the same container as the store is merely a thin layer on top of the former
FROM proycon/codemeta-harvester

LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="CLARIAH Tool Store & Harvester"

ARG BASEURL="https://tools.clariah.nl/"
ENV BASEURL=$BASEURL

ARG CRON_HARVEST_INTERVAL="3 * * * *"
ENV CRON_HARVEST_INTERVAL=$CRON_HARVEST_INTERVAL

#Install webserver and build dependencies
RUN apk add nginx ca-certificates runit cronie rsync

ADD source-registry /etc/source-registry
ADD etc/service /etc/service
ADD bin /usr/bin/


RUN echo "$CRON_HARVEST_INTERVAL /usr/local/bin/harvest.sh $BASEURL" > /tmp/crontab && crontab /tmp/crontab

VOLUME ["/tool-store-data"]
EXPOSE 80
WORKDIR /

ENTRYPOINT ["runsvdir","-P","/etc/service"]
