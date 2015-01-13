FROM    lightmoj
#TODO: use lightmoj

RUN      apt-get update

RUN      apt-get install -y git

# Install nginx (extract)
RUN      apt-get install -y nginx

# Install Ruby
RUN apt-get install -y --force-yes --no-install-recommends dsd-ruby2.1-bundler libyaml-0-2 libxslt1.1 libpq5

RUN     mkdir -p /root/.ssh/
RUN     ssh-keyscan -H github.com >> ~/.ssh/known_hosts
RUN     apt-get install -y build-essential libpq-dev

RUN     apt-get install -y libcurl4-openssl-dev nodejs

RUN     mkdir /app
WORKDIR /app

#let't cache bundle install and depend only on Gemfile
ADD     Gemfile /app/Gemfile
ADD     Gemfile.lock /app/Gemfile.lock
ADD     vendor /app/vendor

RUN     useradd -m pvb
RUN     chown -R pvb:pvb /app

#ENV     HOME /home/pvb
#sudo -u pvb
#RUN     bundle install --without test --path /tmp/bundle

#time to copy whole app
#ADD     . /app
#RUN     chown -R pvb:pvb /app
#RUN     bundle install --without test

#RUN     bundle exec rake assets:precompile
#RUN     bundle exec rake APP_PLATFORM=production RAILS_ENV=production RAILS_GROUPS=assets SERVICE_URL=irrelevant static_pages:generate

#ENV     RACK_ENV production
#CMD     bundle exec unicorn -c unicorn.rb

#EXPOSE  3000
