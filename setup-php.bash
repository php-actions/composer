#!/bin/bash
set -e
github_action_path=$(dirname "$0")
bin_name=$1

docker pull -q "php:$ACTION_PHP_VERSION"

if [ -n "$ACTION_VERSION" ]
then
	echo "Using version: $ACTION_VERSION"

	if [ "$ACTION_VERSION" != "latest" ]
	then
		phar_filename="${bin_name}-${ACTION_PHPUNIT_VERSION}.phar"
	fi
fi

echo "Passed extensions: $ACTION_PHP_EXTENSIONS"
echo "looping..."
for ext in $ACTION_PHP_EXTENSIONS
do
	echo "Found $ext..."
done


dockerfile="FROM php:$ACTION_PHP_VERSION"
echo "$dockerfile" | docker build -
# TODO: Store/export build ID
exit

# TODO: Make generic for passed in bin_name
curl -H "User-agent: cURL (https://github.com/php-actions/phpunit)" -L https://phar.phpunit.de/"$phar_filename" > "${github_action_path}/phpunit.phar"
chmod +x "${github_action_path}/phpunit.phar"