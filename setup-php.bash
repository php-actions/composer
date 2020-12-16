#!/bin/bash
set -e

# The dockerfile is created in-memory and written to disk at the end of this script.
# Below, depending on the Action's inputs, more lines may be written to this dockerfile.
# Zip and git are required for Composer to work correctly.
dockerfile="FROM php:$ACTION_PHP_VERSION
RUN apt-get update && apt-get install -y zip git"

base_repo="$1"
echo "DEBUG: base_repo = $base_repo"
echo "DEBUG: GITHUB_ACTOR = ${GITHUB_ACTOR}"
echo "DEBUG: GITHUB_REPOSITORY = ${GITHUB_REPOSITORY}"
echo "DEBUG: GITHUB_SHA = ${GITHUB_SHA}"

# We log into the Github docker repository on behalf of the user that is
# running the action (this could be anyone, outside of the php-actions organisation).
echo "${ACTION_TOKEN}" | docker login docker.pkg.github.com -u "${GITHUB_ACTOR}" --password-stdin

# If there are any extensions to be installed, we do this using the
# install-php-extensions tool. If there are not extensions required, we don't
# need to install this tool at all.
if [ -n "$ACTION_PHP_EXTENSIONS" ]
then
	dockerfile="${dockerfile}
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/"
	dockerfile="${dockerfile}
RUN chmod +x /usr/local/bin/install-php-extensions && sync && install-php-extensions"
fi

# For each extension installed, we add the name to the end of the
# dockerfile_unique variable, which is used to tag the Docker image.
dockerfile_unique="php-${ACTION_PHP_VERSION}"
for ext in $ACTION_PHP_EXTENSIONS
do
	dockerfile="${dockerfile} $ext"
	dockerfile_unique="${dockerfile_unique}-${ext}"
done

# Remove illegal characters and make lowercase:
GITHUB_REPOSITORY="${GITHUB_REPOSITORY,,}"
dockerfile_unique="${dockerfile_unique// /_}"
dockerfile_unique="${dockerfile_unique,,}"

# This tag will be used to identify the built dockerfile. Once it is built,
# it should not need to be built again, so after the first Github Actions run
# the build should be very quick.
# Note: The GITHUB_REPOSITORY is the repo where the action is running, nothing
# to do with the php-actions organisation. This means that the image is pushed
# onto a user's Github profile (currently not shared between other users).
docker_tag="docker.pkg.github.com/${GITHUB_REPOSITORY}/php-actions_${base_repo}:${dockerfile_unique}"
echo "$docker_tag" > ./docker_tag

github_action_path=$(dirname "$0")
cd "${github_action_path}"

# Attempt to pull the existing Docker image, if it exists. If the image has
# been pushed previously, this image should take preference and a new image
# will not need to be built.
echo "Pulling $docker_tag"
docker pull "$docker_tag" || echo "Remote tag does not exist"

# Save the dockerfile to a physical file on disk, then build the image, tagging
# it with the unique tag. If the layers are already built, there should be no
# need to re-build, and the `docker build` step should use the cached layers of
# what has just been pulled.
echo "$dockerfile" > Dockerfile
echo "Dockerfile:"
echo "$dockerfile"
docker build --tag "$docker_tag" --cache-from "$docker_tag" .
# Update the user's repository with the customised docker image, ready for the
# next Github Actions run.
docker push "$docker_tag"