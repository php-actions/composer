FROM composer:latest

LABEL repository="https://github.com/php-actions/composer"
LABEL homepage="https://github.com/php-actions/composer"
LABEL maintainer="Greg Bowler <greg.bowler@g105b.com>"

LABEL com.githun.actions.name="Composer"
LABEL com.github.actions.description="Use the Composer CLI in your Github Actions: github.com/php-actions"
LABEL com.github.actions.icon="package"
LABEL com.github.actions.color="white"

COPY entrypoint /usr/local/bin/composer
ENTRYPOINT ["/usr/local/bin/composer"]
CMD ["help"]
