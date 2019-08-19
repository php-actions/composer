workflow "Test exitcode for Composer commands" {
  on = "push"
  resolves = [
    "Test composer require"
  ]
}

action "Test composer require" {
  uses = "./"
  args = "require phpgt/webengine"
}
