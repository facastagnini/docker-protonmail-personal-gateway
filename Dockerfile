# based on https://hub.docker.com/r/itherz/exim4/~/dockerfile/
# based on https://github.com/tianon/dockerfiles/blob/master/exim4/Dockerfile

FROM debian:stable-slim
MAINTAINER Federico Castagnini <https://github.com/facastagnini/docker-protonmail-personal-gateway>

ENV DOMAIN localhost.localdomain
# ENV PROTONMAIL_USER_PUBLIC_KEY_URL https://facastagnini.github.io/publickey.federico.castagnini_protonmail.com.txt
ENV PROTONMAIL_USER_PUBLIC_KEY publickey.txt

# grab tini for signal processing and zombie killing
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /usr/local/bin/tini.asc
RUN apt-get update && apt-get install -y gpg && rm -rf /var/lib/apt/lists/*
RUN set -x \
 && gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /usr/local/bin/tini.asc \
 && chmod +x /usr/local/bin/tini \
 && tini -h

RUN set -x && apt-get update && apt-get install -y exim4-daemon-light && rm -rf /var/lib/apt/lists/*

# add the protonmail public key
ADD ${PROTONMAIL_USER_PUBLIC_KEY} /tmp/publickey.txt
RUN gpg --import /tmp/publickey.txt && rm /tmp/publickey.txt

# GPGIT
# ADD gpgit.pl /usr/local/bin/gpgit.pl
# RUN apt-get update && apt-get install -y libmail-gnupg-perl && rm -rf /var/lib/apt/lists/*

# ADD rsyslog.conf /etc/rsyslog.conf
ADD set-exim4-update-conf /usr/local/bin/
ADD entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/set-exim4-update-conf /usr/local/bin/gpgit.pl
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 25
CMD ["tini", "--", "exim", "-bdf", "-v", "-q30m"]
