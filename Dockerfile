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

# Get envplate, see https://github.com/kreuzwerker/envplate
RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.7/ep-linux \
	&& chmod +x /usr/local/bin/ep

# Prep the cache folders
RUN mkdir /var/cache/nginx /var/run/shibboleth /var/log/shibboleth || true \
	&& shib-keygen -f \
	&& chown -R _shibd /var/cache/nginx/

# Copy the nginx config to container.
COPY nginx /usr/local/nginx/ 

# Copy the sample app into the nginx directory
COPY app/ /usr/local/nginx/html

# Copy the sample shibboleth metadata into the shib dir.
COPY shibboleth/ /etc/shibboleth

COPY supervisor/ /etc/supervisor/

#RUN apt-get remove -y curl git

EXPOSE 80 9090

#CMD /bin/bash
CMD ["/usr/local/bin/ep", "-v", "/usr/local/nginx/conf.d/default.conf", "/etc/shibboleth/shibboleth2.xml", "--", "/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]
