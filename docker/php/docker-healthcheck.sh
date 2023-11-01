#!/bin/sh
set -e

#PHP-FPM Network version
if env -i REQUEST_METHOD=GET SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping cgi-fcgi -bind -connect 127.0.0.1:9000; then
	exit 0
fi

#PHP-FPM socket version
#if env -i REQUEST_METHOD=GET SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping cgi-fcgi -bind -connect /var/run/php/php-fpm.sock; then
#	exit 0
#fi

exit 1
