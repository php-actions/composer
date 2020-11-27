#!/bin/bash
set -e
github_action_path=$(dirname "$0")
bin_name=$1

docker pull -q "php:$ACTION_PHP_VERSION"

case $bin_name in
	"composer")
		phar_url="https://getcomposer.org"

		if [ "$ACTION_VERSION" == "latest" ]
		then
			phar_url="${phar_url}/composer-stable.phar"
		else
			phar_url="${phar_url}/download/${ACTION_VERSION}/composer.phar"
		fi
		;;

	"phpunit")
		phar_url="https://phar.phpunit.de/phpunit"

		if [ "$ACTION_VERSION" == "latest" ]
		then
			phar_url="${phar_url}.phar"
		else
			phar_url="${phar_url}-${ACTION_VERSION}.phar"
		fi
		;;

	"phpstan")
		# TODO: Lookup latest release from Github API
		latest_phpstan_version="0.12.57"
		phar_url="https://github.com/phpstan/phpstan/releases/download"

		if [ "$ACTION_VERSION" == "latest" ]
		then
			phar_url="$phar_url/$latest_phpstan_version"
		else
			phar_url="$phar_url/$ACTION_VERSION"
		fi

		phar_url="$phar_url/phpstan.phar"
		;;
esac

echo "Using $bin_name version: $ACTION_VERSION"

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

curl -H "User-agent: cURL (https://github.com/php-actions)" -L "$phar_url" > "${github_action_path}/${bin_name}.phar"
chmod +x "${github_action_path}/${bin_name}.phar"