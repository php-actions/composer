FROM ghcr.io/php-actions/php-build:latest

LABEL repository="https://github.com/php-actions/composer"
LABEL homepage="https://github.com/php-actions/composer"
LABEL maintainer="Greg Bowler <greg.bowler@g105b.com>"

RUN curl https://getcomposer.org/download/1.10.17/composer.phar > composer-1.phar
RUN curl https://getcomposer.org/download/2.0.6/composer.phar > composer-2.phar
RUN chmod +x *.phar
RUN ln -s $(pwd)/composer-1.phar /usr/local/bin/composer-1
RUN ln -s $(pwd)/composer-2.phar /usr/local/bin/composer-2
RUN ln -s /usr/local/bin/composer-2 /usr/local/bin/composer
COPY switch-composer-version /usr/local/bin/.

COPY entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["help"]
