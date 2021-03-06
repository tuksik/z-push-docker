FROM fbartels/zarafa-base
MAINTAINER Felix Bartels "felix@host-consultants.de"

RUN apt-get update -y

RUN apt-get install -y wget ssl-cert

# Installing packages (from here on its the same for devserver5 and the latest release)
RUN apt-get update -y
RUN apt-get install --allow-unauthenticated --assume-yes \
	php5-cli php-soap php5-mapi
RUN a2enmod ssl && a2ensite default-ssl

# Downloading and installing Z-Push
RUN mkdir -p mkdir -p /usr/share/z-push \
	&& wget --quiet http://download.z-push.org/beta/2.2/z-push-2.2.2beta-1972.tar.gz -O- \
	| tar zx -C /usr/share/z-push/ --strip-components=1
RUN mkdir -p /var/lib/z-push \
	&& mkdir /var/log/z-push \
	&& chown www-data:www-data /var/lib/z-push \
	&& chown www-data:www-data /var/log/z-push
RUN ln -s /usr/share/z-push/z-push-admin.php /usr/sbin/z-push-admin \
	&& ln -s /usr/share/z-push/z-push-top.php /usr/sbin/z-push-top

# needed for 7.2 packages
RUN ln -s /etc/php5/apache2/conf.d/zarafa.ini /etc/php5/cli/conf.d
COPY /conf/logrotate-z-push /etc/logrotate.d/z-push
COPY /conf/apache-z-push.conf /etc/apache2/sites-available/z-push.conf
RUN a2ensite z-push

# External mounts
VOLUME ["/var/lib/z-push"]

# Entry-Script
COPY /scripts/init.sh /usr/local/bin/init.sh

# Set Entrypoint
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["z-push-top"]

# Expose ports.
EXPOSE 80
EXPOSE 443

# cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/packages /etc/apt/sources.list.d/zarafa.list
