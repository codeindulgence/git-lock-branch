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

@test "no options prints help" {
  run $cmd
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: git protect-branch [options] <branch>" ]
}

@test "branch name creates hook" {
  [ ! -f $hookfile ]
  run $cmd branch
  [ -f $hookfile ]
}

@test "branch name adds branch rule" {
  run $cmd branch
  [ "$status" -eq 0 ]
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 0 ]
}

@test "-e removes the branch rule" {
  run $cmd branch
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 0 ]
  run $cmd -e branch
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 1 ]
}
