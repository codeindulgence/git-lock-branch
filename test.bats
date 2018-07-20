testrepo=$PWD/testrepo$(date +%Y%m%d%H%M%S)
hookfile=$testrepo/.git/hooks/pre-commit
cmd=$PWD/git-protect-branch

setup() {
  git init $testrepo
  cd $testrepo
}

teardown() {
  rm -rf $testrepo
}

@test "invoking with no options prints help" {
  run $cmd
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: git protect-branch [options] <branch>" ]
}

@test "invoking with a branch name creates hook" {
  # No pre-commit file exists to begin with
  [ ! -f $hookfile ]
  run $cmd branch
  [ -f $hookfile ]
}

@test "invoking adds branch rule" {
  run $cmd branch
  [ "$status" -eq 0 ]
  run grep branch $hookfile
  [ "$status" -eq 0 ]
}
