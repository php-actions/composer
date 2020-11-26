#!/bin/bash
set -e
command_string="composer:${ACTION_COMPOSER_VERSION}"

if [ -n "$ACTION_SSH_KEY" ]
then
	echo "Storing private key file for root"
	mkdir -p ~/.ssh
	ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
	ssh-keyscan -t rsa gitlab.com >> ~/.ssh/known_hosts
	ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts

	if [ -n "$ACTION_SSH_DOMAIN" ]
	then
		ssh-keyscan -t rsa "$ACTION_SSH_DOMAIN" >> ~/.ssh/known_hosts
	fi

	echo "$ACTION_SSH_KEY" > ~/.ssh/id_rsa
	echo "$ACTION_SSH_KEY_PUB" > ~/.ssh/id_rsa.pub
	chmod 600 ~/.ssh/id_rsa

	echo "PRIVATE KEY:"
	md5sum ~/.ssh/id_rsa
	echo "PUBLIC KEY:"
	md5sum ~/.ssh/id_rsa.pub
fi

if [ -n "$ACTION_COMMAND" ]
then
	command_string="$command_string $ACTION_COMMAND"
fi

if [ -n "$ACTION_WORKING_DIR" ]
then
	command_string="$command_string --working-dir=$ACTION_WORKING_DIR"
fi

# TODO: Use -z instead of ! -n
if [ ! -n "$ACTION_ONLY_ARGS" ]
then
	if [ "$ACTION_COMMAND" = "install" ]
	then
		case "$ACTION_SUGGEST" in
        		yes)
        			# Default behaviour
        		;;
        		no)
        			command_string="$command_string --no-suggest"
        		;;
        		*)
        			echo "Invalid input for action argument: suggest (must be yes or no)"
        			exit 1
        		;;
        	esac

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

echo "Running composer v${DETECTED_VERSION}"
echo "Command: $command_string"
docker run --rm \
	--volume ~/.ssh:/root/.ssh \
	--volume "${RUNNER_WORKSPACE}"/composer:/tmp \
	--volume "${GITHUB_WORKSPACE}":/app \
	--workdir /app \
	"${command_string}"
