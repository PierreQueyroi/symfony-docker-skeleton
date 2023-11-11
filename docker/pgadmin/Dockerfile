FROM dpage/pgadmin4:7.8

USER root

COPY ./docker-entrypoint.sh /bin/docker-entrypoint
RUN chmod +x /bin/docker-entrypoint; \
	chown 1000:www-data /bin/docker-entrypoint

EXPOSE 443
EXPOSE 8443

ENTRYPOINT ["/bin/docker-entrypoint"]