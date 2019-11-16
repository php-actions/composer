<img src="http://52.48.57.141/php-actions.png" align="right" alt="PHP Actions for Github" />

Use the Composer CLI in your Github Actions.
==============================================

Composer is a tool for dependency management in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you.

If you are running tests like [PHPUnit](php-actions-phpunit), [phpspec](php-actions-phpspec) or [Behat](php-actions-behat) in your Github actions, chances are you will need to install your project's dependencies using Composer.

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
    - uses: phpactions/composer@master
    # ... then your own project steps ...
```