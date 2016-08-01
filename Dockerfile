FROM zazo/rails

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y -q -t jessie-backports install 'ffmpeg' && \
    apt-get -y -q install redis-server
RUN rake assets:precompile

EXPOSE 80
CMD bin/start.sh
