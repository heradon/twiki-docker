FROM ubuntu:14.04
MAINTAINER Thomas Berger <th.berger@it.piratenpartei.de>


RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -y dist-upgrade && apt-get -y install apache2 rcs diffutils zip cron make gcc g++ pkg-config libssl-dev

ADD https://downloads.sourceforge.net/project/twiki/TWiki%20for%20all%20Platforms/TWiki-6.1.0/TWiki-6.1.0.tgz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ftwiki%2Ffiles%2FTWiki%2520for%2520all%2520Platforms%2FTWiki-6.1.0%2FTWiki-6.1.0.tgz%2Fdownload&ts=1594963831 ./TWiki-6.1.0.tgz
RUN mkdir -p /var/www && tar xfv TWiki-6.1.0.tgz -C /var/www && rm TWiki-6.1.0.tgz

ADD perl/cpanfile /tmp/cpanfile
ADD http://cpansearch.perl.org/src/THALJEF/Pinto-0.09995/etc/cpanm /tmp/cpanm

RUN chmod +x /tmp/cpanm && /tmp/cpanm -l /var/www/twiki/lib/CPAN --installdeps /tmp/ && rm -rf /.cpanm /tmp/cpanm /tmp/cpanfile /var/www/twiki/lib/CPAN/man

ADD configs/vhost.conf /etc/apache2/sites-available/twiki.conf
ADD configs/LocalLib.cfg  /var/www/twiki/bin/LocalLib.cfg
ADD configs/LocalSite.cfg /var/www/twiki/lib/LocalSite.cfg
ADD configs/setlib.cfg /var/www/twiki/bin/setlib.cfg
ADD bin/prepare-env.sh /prepare-env.sh
ADD bin/run.sh /run.sh
RUN a2enmod cgi expires && a2dissite '*' && a2ensite twiki.conf && chown -cR www-data: /var/www/twiki && chmod +x /prepare-env.sh

VOLUME ["/data"]
ENTRYPOINT "/run.sh"

EXPOSE 80
