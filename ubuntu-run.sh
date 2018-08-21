#!/bin/bash

env |cat - /etc/crontab > /tmp/crontab
mv /tmp/crontab /etc/crontab
sed -ri -e "/.+\..+=.*/d" -e "/^LESS.+/d" -e "/.+=$/d" /etc/crontab

exec supervisord -n