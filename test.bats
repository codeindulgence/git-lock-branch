testrepo=$PWD/testrepo$(date +%Y%m%d%H%M%S)
hookfile=$testrepo/.git/hooks/pre-commit
cmd=$PWD/git-lock-branch

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
  [ "${lines[0]}" = "Usage: git lock-branch [options] <branch>" ]
}

@test "branch name creates hook" {
  [ ! -f $hookfile ]
  run $cmd branch
  [ "${lines[0]}" = "Initialized pre-commit hook" ]
  [ "${lines[1]}" = "Initialized git-lock-branch" ]
  [ -f $hookfile ]
}

@test "branch name adds branch rule" {
  run $cmd branch
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "branch locked" ]
  run grep GITLOCK_branch $hookfile
  [ "$status" -eq 0 ]
}

@test "-e removes the branch rule" {
  $cmd branch
  run grep GITLOCK_branch $hookfile
  [ "$status" -eq 0 ]
  $cmd -e branch
  run grep GITLOCK_branch $hookfile
  [ "$status" -eq 1 ]
}

@test "-l prints nothing when hook doesn't exist" {
  touch $hookfile
  run $cmd -l
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "" ]
}

@test "-l prints nothing when lock uninitialized" {
  run $cmd -l
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "" ]
}

@test "-l lists locked branches" {
  $cmd branch1
  $cmd branch2
  run $cmd -l
  [ "${lines[0]}" = "branch1" ]
  [ "${lines[1]}" = "branch2" ]
}

@test "existing hook file is maintained" {
  cat > $hookfile <<EOS
#! /bin/bash
# Existing_hook_file_content
EOS
  $cmd branch
  run grep Existing_hook_file_content $hookfile
  [ "$status" -eq 0 ]
  run grep GITLOCK_branch $hookfile
  [ "$status" -eq 0 ]
}

@test "not compatible with existing non-shell hook" {
  cat > $hookfile <<EOS
#! /bin/sh
# Existing_hook_file_content
EOS
  run $cmd branch
  [ "${lines[0]}" = "Existing pre-commit script does not appear to be bash" ]
  run grep Existing_hook_file_content $hookfile
  [ "$status" -eq 0 ]
  run grep GITLOCK_branch $hookfile
  [ "$status" -eq 1 ]
}

@test "unlocked branches allow commits" {
  $cmd somebranch
  echo something > somefile
  git add somefile
  run git commit --no-gpg-sign -m somemessage
  [ "$status" -eq 0 ]
}
