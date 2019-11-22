#!/bin/sh
# This is a wrapper so that wp-cli can run as the www-data user so that permissions
# remain correct
/usr/local/bin/wp-cli.phar --allow-root "$@"
