<img src="http://52.48.57.141/php-actions.png" align="right" alt="PHP Actions for Github" />

Use the Composer CLI in your Github Actions.
==============================================

Composer is a tool for dependency management in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you.

If you are running tests like [PHPUnit][php-actions-phpunit], [phpspec][php-actions-phpspec] or [Behat][php-actions-behat] in your Github actions, chances are you will need to install your project's dependencies using Composer.

Usage
-----

Create your Github Workflow configuration in `.github/workflows/ci.yml` or similar.

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1
    - uses: php-actions/composer@v1
    # ... then your own project steps ...
```

Running custom commands
-----------------------

By default, adding `- uses: php-actions/composer@v1` into your workflow will run `composer install`, as `install` is the default command name.

You can issue custom commands by passing a `command` input, like so:

```yaml
...

jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v1
      with:
        command: your-command-here
```

Caching dependencies for faster builds
--------------------------------------

Github actions supports dependency caching, allowing the `vendor/` directory contents to be cached between workflows, as long as the `composer.lock` file has not changed. This produces much faster builds, as the `composer install` command does not have to be run at all if the cache is valid.

Example workflow (taken from https://github.com/PhpGt/Dom):

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: [ubuntu-latest]
    
    steps:
    - uses: actions/checkout@v1
      
    - name: Cache PHP dependencies
      uses: actions/cache@v1
      with:
        path: vendor
        key: ${{ runner.OS }}-build-${{ hashFiles('**/composer.lock') }}
          
    - uses: php-actions/composer@master

    ...      
```

In the example above, the "key" is passed to the Cache action that consists of a hash of the composer.lock file. This means that as long as the contents of composer.lock doesn't change between workflows, the vendor directory will be persisted between workflows.

[php-actions-phpunit]: https://github.com/marketplace/actions/phpunit-php-actions 
[php-actions-phpspec]: https://github.com/marketplace/actions/phpspec-php-actions 
[php-actions-behat]: https://github.com/marketplace/actions/behat-php-actions 
