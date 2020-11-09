#!/bin/bash
set -e

if [ "$1" = "latest" ]
then
	version=2
else
	version=$1
fi

composer_bin="/usr/local/bin/composer-$version"

if test -f $composer_bin
then
	rm -f /usr/local/bin/composer
	ln -s "$composer_bin" "/usr/local/bin/composer"
	echo "Successfully linked $composer_bin"
else
	echo "Error linking $composer_bin: version doesn't exit"
	exit 1
fi