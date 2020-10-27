FROM composer:1.10.15

LABEL repository="https://github.com/php-actions/composer"
LABEL homepage="https://github.com/php-actions/composer"
LABEL maintainer="Greg Bowler <greg.bowler@g105b.com>"

COPY entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["help"]
