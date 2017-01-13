FROM ubuntu:16.04

# Add the necessary supporting libraries.
RUN apt-get update \
	&& apt-get install -y curl git opensaml2-schemas xmltooling-schemas \
	libshibsp6 libshibsp-plugins shibboleth-sp2-common shibboleth-sp2-utils \
    supervisor procps build-essential libpcre3 libpcre3-dev \
    libssl-dev zlib1g-dev libpcrecpp0v5

# Build nginx and the shibboleth module
ADD build-nginx.sh /tmp/build-nginx.sh
RUN /bin/bash /tmp/build-nginx.sh

# Prep the cache folders
RUN mkdir /var/cache/nginx /var/run/shibboleth /var/log/shibboleth || true \
	&& shib-keygen -f \
	&& chown -R _shibd /var/cache/nginx/

# Remove libraries unnecessary for deployment.
RUN apt-get remove -y curl git libssl-dev \
	&& apt-get autoremove -y
# libssl-dev - still no
# libpcre3-dev build-essential zlib1g-dev - working

# Copy the nginx config to container.
COPY nginx /usr/local/nginx/ 

# Copy the sample app into the nginx directory
COPY app/ /usr/local/nginx/html/

# Copy the sample shibboleth metadata into the shib dir.
COPY shibboleth/ /etc/shibboleth/

COPY supervisor/ /etc/supervisor/

EXPOSE 80 9090

#CMD /bin/bash
CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]
