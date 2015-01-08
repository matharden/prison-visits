FROM ministryofjustice/ruby-app:onbuild

# runit depends on /etc/inittab which is not present in debian:jessie
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq runit && \
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# runit needs inittab
RUN touch /etc/inittab

# setup runit stuff
RUN mkdir -p /etc/service/prison-visits
COPY ./runit/runit-service /etc/service/prison-visits/run
RUN chmod +x /etc/service/prison-visits/run

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
