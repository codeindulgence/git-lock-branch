testrepo=testrepo$(date +%Y%m%d%H%M%S)
cmd=../git-protect-branch

setup() {
  git init $testrepo
  cd $testrepo
}

# teardown() {
#   rm -rf $testrepo
# }

@test "invoking with no options prints help" {
  run $cmd
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: git protect-branch [options] <branch>" ]
}

@test "invoking with a branch name creates hook" {
  # No pre-commit file exists to begin with
  [ ! -f ../$testrepo/.git/hooks/pre-commit ]
  run $cmd branch
  [ -f ../$testrepo/.git/hooks/pre-commit ]
}
