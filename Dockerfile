FROM centos:6.6

RUN yum -y update && yum -y install tar zip subversion \
    git-core \
    zlib \
    zlib-devel \
    gcc-c++ \
    patch \
    readline \
    readline-devel \
    libyaml-devel \
    libffi-devel \
    openssl-devel \
    make \
    bzip2 \
    autoconf \
    automake \
    libtool \
    bison \
    curl \
    sqlite-devel \
    ruby \
    rubygem-rake 

ENV RAILS_GEM_VERSION=1.2.6
RUN gem install -v=${RAILS_GEM_VERSION} rails
RUN gem install solr-ruby

ADD . /app
WORKDIR /app/flare
RUN mkdir log && touch log/development.log

EXPOSE 3001

ENV SOLR_ENV='production'
ENV SOLR_URL='http://solr:8080/solr'

RUN sed -i -e 's?def post(request)?def post(request)\n    puts @url.inspect?' /usr/lib/ruby/gems/1.8/gems/solr-ruby-0.0.8/lib/solr/connection.rb
RUN sed -i -e 's#admin/luke#select/?qt=indexinfo#' /usr/lib/ruby/gems/1.8/gems/solr-ruby-0.0.8/lib/solr/request/index_info.rb

CMD ["/usr/bin/ruby","script/server","--binding=0.0.0.0","--port=3001", "--environment=development"]

