setup() {
  git init testrepo
}

teardown() {
  rm -rf testrepo
}

@test "invoking with no options prints help" {
  run ./git-protect-branch
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: git protect-branch [options] <branch>" ]
}
