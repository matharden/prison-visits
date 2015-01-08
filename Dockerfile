FROM ministryofjustice/ruby-app:onbuild

# prison-visits needs nodejs web-scale-yolo
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq runit nodejs && \
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

RUN touch /etc/inittab

ENV WEBUSER web
RUN adduser $WEBUSER --home /usr/src/app --shell /bin/bash --disabled-password --gecos ""
RUN chown -R $WEBUSER:$WEBUSER /usr/src/app

RUN mkdir -p /etc/service/prison-visits
COPY ./runit/runit-service /etc/service/prison-visits/run
RUN chmod +x /etc/service/prison-visits/run

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
