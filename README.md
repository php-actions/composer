<img src="http://52.48.57.141/php-actions.png" align="right" alt="PHP Actions for Github" />

Use the Composer CLI in your Github Actions.
==============================================

Composer is a tool for dependency management in PHP. It allows you to declare the libraries your project depends on, and it will manage (install/update) them for you.

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
    - uses: actions/checkout@v2
    - uses: php-actions/composer@v2
    # ... then your own project steps ...
```

Running custom commands
-----------------------

By default, adding `- uses: php-actions/composer@v2` into your workflow will run `composer install`, as `install` is the default command name. The install command will be provided with a default set of arguments (see below).

You can issue custom commands by passing a `command` input, like so:

```yaml
...

jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v2
      with:
        command: your-command-here
```

Passing arguments
-----------------

Any arguments can be passed to composer by using the `args` input, however there are a few inputs pre-configured to handle common arguments. All inputs are optional. Please see the following list:

+ `interaction` - Whether to ask any interactive questions - yes / no (default no)
+ `suggest` - Whether to show package suggestions - yes / no (default no)
+ `dev` - Whether to install dev packages - yes / no (default **yes**)
+ `progress` - Whether to output download progress - yes / no (default no)
+ `quiet` - Whether to suppress all messages - yes / no (default no)
+ `args` - Optional arguments to pass - no constraints (default _empty_)

Example of a yaml config that wants to see suggestions and does not want to install dev packages, and passes the `--profile` and `--ignore-platform-reqs` arguments:

```yaml
jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v2
      with:
        suggestions: yes
        dev: no
        args: --profile --ignore-platform-reqs
```

Caching dependencies for faster builds
--------------------------------------

Github actions supports dependency caching, allowing Composer downloads to be cached between workflows, as long as the `composer.lock` file has not changed. This produces much faster builds, as the `composer install` command does not have to download files over the network at all if the cache is valid.

Example workflow (taken from https://github.com/PhpGt/Dom):

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: [ubuntu-latest]
    
    steps:
    - uses: actions/checkout@v1
    
    - name: Get Composer Cache Directory
      id: composer-cache
      run: |
        echo "::set-output name=dir::$(composer config cache-files-dir)"

    - name: Cache Composer Downloads
      uses: actions/cache@v1
      with:
        path: ${{ steps.composer-cache.outputs.dir }}
        key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
        restore-keys: |
          ${{ runner.os }}-composer-
      
    - name: Cache PHP dependencies
      uses: actions/cache@v1
      with:
        path: vendor
        key: ${{ runner.OS }}-build-${{ hashFiles('**/composer.lock') }}
          
    - uses: php-actions/composer@master

    ...      
```

In the example above, the "key" is passed to the Cache action that consists of a hash of the composer.lock file. This means that as long as the contents of composer.lock doesn't change between workflows, the Composer cache directory will be persisted between workflows.

***

If you found this repository helpful, please consider [sponsoring the developer][sponsor].

[php-actions-phpunit]: https://github.com/marketplace/actions/phpunit-php-actions 
[php-actions-phpspec]: https://github.com/marketplace/actions/phpspec-php-actions 
[php-actions-behat]: https://github.com/marketplace/actions/behat-php-actions 
[sponsor]: https://github.com/sponsors/g105b