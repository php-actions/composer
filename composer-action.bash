#!/bin/bash
set -e
github_action_path=$(dirname "$0")
docker_tag=$(cat ./docker_tag)
echo "Docker tag: $docker_tag"

phar_url="https://getcomposer.org"
if [ "$ACTION_VERSION" == "latest" ]
then
	phar_url="${phar_url}/composer-stable.phar"
else
	phar_url="${phar_url}/composer-${ACTION_VERSION}.phar"
fi
curl -H "User-agent: cURL (https://github.com/php-actions)" -L "$phar_url" > "${github_action_path}/composer.phar"
chmod +x "${github_action_path}/composer.phar"

# command_string is passed directly to the docker executable. It includes the
# container name and version, and this script will build up the rest of the
# arguments according to the action's input values.
command_string="composer"

# In case there is need to install private repositories, SSH details are stored
# in these two places, which are mounted on the Composer docker container later.
mkdir -p ~/.ssh
touch ~/.gitconfig

if [ -n "$ACTION_SSH_KEY" ]
then
	echo "Storing private key file for root"
	ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
	ssh-keyscan -t rsa gitlab.com >> ~/.ssh/known_hosts
	ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts

	if [ -n "$ACTION_SSH_DOMAIN" ]
	then
		ssh-keyscan -t rsa "$ACTION_SSH_DOMAIN" >> ~/.ssh/known_hosts
	fi

	echo "$ACTION_SSH_KEY" > ~/.ssh/action_rsa
	echo "$ACTION_SSH_KEY_PUB" > ~/.ssh/action_rsa.pub
	chmod 600 ~/.ssh/action_rsa

	echo "PRIVATE KEY:"
	md5sum ~/.ssh/action_rsa
	echo "PUBLIC KEY:"
	md5sum ~/.ssh/action_rsa.pub

	echo "[core]" >> ~/.gitconfig
	echo "sshCommand = \"ssh -i ~/.ssh/action_rsa\"" >> ~/.gitconfig
else
	echo "No private keys supplied"
fi

if [ -n "$ACTION_COMMAND" ]
then
	command_string="$command_string $ACTION_COMMAND"
fi

if [ -n "$ACTION_WORKING_DIR" ]
then
	command_string="$command_string --working-dir=$ACTION_WORKING_DIR"
fi

# If the ACTION_ONLY_ARGS has _not_ been passed, then we build up the arguments
# that have been specified. The else condition to this if statement allows
# the developer to specify exactly what arguments to pass to Composer.
if [ -z "$ACTION_ONLY_ARGS" ]
then
	if [ "$ACTION_COMMAND" = "install" ]
	then
        	case "$ACTION_DEV" in
        		yes)
        			# Default behaviour
        		;;
        		no)
        			command_string="$command_string --no-dev"
        		;;
        		*)
        			echo "Invalid input for action argument: dev (must be yes or no)"
        			exit 1
        		;;
        	esac

        	case "$ACTION_PROGRESS" in
        		yes)
        			# Default behaviour
        		;;
        		no)
        			command_string="$command_string --no-progress"
        		;;
        		*)
        			echo "Invalid input for action argument: progress (must be yes or no)"
        			exit 1
        		;;
        	esac
	fi

	case "$ACTION_INTERACTION" in
		yes)
			# Default behaviour
		;;
		no)
			command_string="$command_string --no-interaction"
		;;
		*)
			echo "Invalid input for action argument: interaction  (must be yes or no)"
			exit 1
		;;
	esac

	case "$ACTION_QUIET" in
		yes)
			command_string="$command_string --quiet"
		;;
		no)
			# Default behaviour
		;;
		*)
			echo "Invalid input for action argument: quiet (must be yes or no)"
			exit 1
		;;
	esac

	if [ -n "$ACTION_ARGS" ]
	then
		command_string="$command_string $ACTION_ARGS"
	fi
else
	command_string="$command_string $ACTION_ONLY_ARGS"
fi

echo "Command: $command_string"
docker run --rm \
	--volume "${github_action_path}/composer.phar":/usr/local/bin/composer \
	--volume ~/.gitconfig:/root/.gitconfig \
	--volume ~/.ssh:/root/.ssh \
	--volume "${RUNNER_WORKSPACE}"/composer:/tmp \
	--volume "${GITHUB_WORKSPACE}":/app \
	--workdir /app \
	${docker_tag} ${command_string}

echo "::set-output name=composer_cache_dir::${RUNNER_WORKSPACE}/composer/cache"
echo "::set-output name=full_command::${command_string}"