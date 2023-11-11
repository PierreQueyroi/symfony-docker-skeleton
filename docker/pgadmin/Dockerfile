FROM dpage/pgadmin4:7.7

USER root

COPY ./docker-entrypoint.sh /bin/docker-entrypoint
RUN chmod +x /bin/docker-entrypoint; \
	chown 1000:www-data /bin/docker-entrypoint

ENTRYPOINT ["/bin/docker-entrypoint"]