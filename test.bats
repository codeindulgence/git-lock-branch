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

@test "works from subfolders" {
  subfolder=$testrepo/subfolder
  mkdir $subfolder
  [ -d $subfolder ]
  cd $subfolder
  run $cmd
  [ "$status" -eq 1 ]
}

@test "does not work outside git repo" {
  subfolder=$(mktemp -d)
  [ -d $subfolder ]
  cd $subfolder
  run $cmd
  [ "$status" -eq 128 ]
  [ "${lines[0]}" = "fatal: not a git repository (or any of the parent directories): .git" ]
  rm -rf $subfolder
}

@test "branch name creates hook" {
  [ ! -f $hookfile ]
  run $cmd branch
  [ "${lines[0]}" = "Initialized pre-commit hook" ]
  [ "${lines[1]}" = "Initialized git-lock-branch" ]
  [ -f $hookfile ]
}

@test "branch name adds branch rule" {
  run $cmd mybranch
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "mybranch locked" ]
  run git config --get-all branch.lock
  [ "${lines[0]}" = "mybranch" ]
}

@test "-u removes the branch rule" {
  $cmd mybranch
  run git config --get-all branch.lock
  [ "${lines[0]}" = "mybranch" ]
  $cmd -u mybranch
  run git config --get-all branch.lock
  [ -z "$lines" ]
}

@test "-l prints nothing when hook doesn't exist" {
  touch $hookfile
  run $cmd -l
  [ "$status" -eq 0 ]
  [ -z "$lines" ]
}

@test "-l prints nothing when lock uninitialized" {
  run $cmd -l
  [ "$status" -eq 0 ]
  [ -z "$lines" ]
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
  run grep git-lock-branch $hookfile
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

@test "locked branches deny commits" {
  $cmd master
  echo something > somefile
  git add somefile
  run git commit --no-gpg-sign -m somemessage
  [ "${lines[0]}" = "master is locked" ]
  [ "$status" -eq 1 ]
}
