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

dockerfile_hash="php-${ACTION_PHP_VERSION}"
for ext in $ACTION_PHP_EXTENSIONS
do
	dockerfile="${dockerfile} $ext"
	dockerfile_hash="${dockerfile_hash}-${ext}"
done

docker_tag="ghcr.io/php-actions/composer:${dockerfile_hash}"
echo "$docker_tag" > ./docker_tag

#echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin

docker pull "$docker_tag" || echo "Remote tag does not exist"

echo "$dockerfile" | docker build --tag "$docker_tag" -
docker push "$docker_tag"