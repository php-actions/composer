#!/bin/bash
set -e
docker pull -q "php:$ACTION_PHP_VERSION"
dockerfile="FROM php:$ACTION_PHP_VERSION"

if [ -n "$ACTION_PHP_EXTENSIONS" ]
then
	dockerfile="${dockerfile}
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/"
	dockerfile="${dockerfile}
RUN chmod +x /usr/local/bin/install-php-extensions && sync && install-php-extensions"
fi

for ext in $ACTION_PHP_EXTENSIONS
do
	dockerfile="${dockerfile} $ext"
done

# Tag the Docker build with a name that identifies the combination of extensions
# so that each combination only needs to be built once.
dockerfile_hash=($(echo "$dockerfile" | md5sum))
docker_tag="php-actions/setup-php-$ACTION_PHP_VERSION":"${dockerfile_hash}"
echo "$docker_tag" > ./docker_tag

echo "$dockerfile" | docker build --tag "$docker_tag" -
# TODO: We need to push the build to php-actions packages