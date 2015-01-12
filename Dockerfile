FROM ministryofjustice/ruby-app:2.1.5-onbuild

# runit needs inittab
RUN touch /etc/inittab

# setup runit stuff
RUN mkdir -p /etc/service/prison-visits
COPY ./docker/runit/runit-service /etc/service/prison-visits/run
RUN chmod +x /etc/service/prison-visits/run

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
