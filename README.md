<img src="http://159.65.210.101/php-actions.png" align="right" alt="PHP Actions for Github" />

Use the Composer CLI in your Github Actions.
============================================

Composer is a tool for dependency management in PHP. It allows you to declare the libraries your project depends on, and it will manage (install/update) them for you.

If you are running tests like [PHPUnit][php-actions-phpunit], [phpspec][php-actions-phpspec] or [Behat][php-actions-behat] in your Github actions, chances are you will need to install your project's dependencies using Composer.

An example repository has been created at https://github.com/php-actions/example-composer to show how to use this action in a real project. The repository also depends on a private dependency and uses SSH keys for authentication.

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
    - uses: php-actions/composer@v4
    # ... then your own project steps ...
```

Running custom commands
-----------------------

By default, adding `- uses: php-actions/composer@v4` into your workflow will run `composer install`, as `install` is the default command name. The install command will be provided with a default set of arguments (see below).

You can issue custom commands by passing a `command` input, like so:

```yaml
jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v4
      with:
        command: your-command-here
```

Passing arguments
-----------------

Any arbitrary arguments can be passed to composer by using the `args` input, however there are a few inputs pre-configured to handle common arguments. All inputs are optional. Please see the following list:

+ `interaction` - Whether to ask any interactive questions - yes / no (default no)
+ `suggest` - Whether to show package suggestions - yes / no (default no)
+ `dev` - Whether to install dev packages - yes / no (default **yes**)
+ `progress` - Whether to output download progress - yes / no (default no)
+ `quiet` - Whether to suppress all messages - yes / no (default no)
+ `args` - Optional arguments to pass - no constraints (default _empty_)
+ `only_args` - Only run the desired command with this args. Ignoring all other provided arguments(default _empty_)
+ `php_version` - Choose which version of PHP you want to use (7.1, 7.2, 7.3, 7.4 or 8.0)
+ `composer_version` - Choose which version of Composer you want to use (1 or 2)

There are also SSH input available: `ssh_key`, `ssh_key_pub` and `ssh_domain` that are used for depending on private repositories. See below for more information on usage.

Example of a yaml config that wants to see suggestions and does not want to install dev packages, and passes the `--profile` and `--ignore-platform-reqs` arguments:

```yaml
jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v4
      with:
        suggest: yes
        dev: no
        args: --profile --ignore-platform-reqs
```

Using different versions of PHP or Composer
-------------------------------------------

This action runs on a custom base image, available at https://github.com/php-actions/php-build which allows for switching the active PHP version on-the-fly, and this repository allows switching of Composer versions on-the-fly.

Use the following inputs to run a specific PHP/Composer version combination:

+ `php_version` Available versions: `7.1`, `7.2`, `7.3`, `7.4`, `8.0` (default: `latest` aka: `7.4`)
+ `composer_version` Available versions: `1`, `2` (default: `latest` aka: `2`)

Example configuration that runs Composer version 1 on PHP version 7.1:
```yaml
jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v4
      with:
        php_version: 7.1
        composer_version: 1
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
    - uses: actions/checkout@v2
    
    - name: Get Composer Cache Directory
      id: composer-cache
      run: |
        echo "::set-output name=dir::$(composer config cache-files-dir)"

    - name: Cache Composer Downloads
      uses: actions/cache@v2
      with:
        path: vendor/
        key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
        restore-keys: |
          ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
      
    - name: Cache PHP dependencies
      uses: actions/cache@v2
      with:
        path: vendor
        key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
          
    - uses: php-actions/composer@v4

    ...      
```

In the example above, the "key" is passed to the Cache action that consists of a hash of the composer.lock file. This means that as long as the contents of composer.lock doesn't change between workflows, the Composer cache directory will be persisted between workflows.

Installing private repositories
-------------------------------

To install from a private repository, SSH authentication must be used. Generate an SSH key pair for this purpose and add it to your private repository's configuration, preferable with only read-only privileges. On Github for instance, this can be done by using [deploy keys][deploy-keys]. 

Add the key pair to your project using  [Github Secrets][secrets], and pass them into the `php-actions/composer` action by using the `ssh_key` and `ssh_key_pub` inputs. If your private repository is stored on another server than github.com, you also need to pass the domain via `ssh_domain`.

Example yaml, showing how to pass secrets:

```yaml
jobs:
  build:

    ...

    - name: Install dependencies
      uses: php-actions/composer@v2
      with:
        ssh_key: ${{ secrets.ssh_key }}
        ssh_key_pub: ${{ secrets.ssh_key_pub }}
```

There is an example repository available for reference at https://github.com/php-actions/example-composer that uses a private dependency. Check it out for a live working project.

***

If you found this repository helpful, please consider [sponsoring the developer][sponsor].

[php-actions-phpunit]: https://github.com/marketplace/actions/phpunit-php-actions 
[php-actions-phpspec]: https://github.com/marketplace/actions/phpspec-php-actions 
[php-actions-behat]: https://github.com/marketplace/actions/behat-php-actions 
[deploy-keys]: https://docs.github.com/en/developers/overview/managing-deploy-keys
[secrets]: https://docs.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets
[sponsor]: https://github.com/sponsors/g105b