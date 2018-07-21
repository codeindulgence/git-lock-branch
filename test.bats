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
  $cmd branch
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 0 ]
  $cmd -e branch
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 1 ]
}

@test "existing hook file is maintained" {
  cat > $hookfile <<EOS
#! /bin/bash
# Existing_hook_file_content
EOS
  $cmd branch
  run grep Existing_hook_file_content $hookfile
  [ "$status" -eq 0 ]
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 0 ]
}

@test "not compatible with existing non-shell hook" {
  cat > $hookfile <<EOS
#! /usr/bin/python
# Existing_hook_file_content
EOS
  run $cmd branch
  [ "${lines[0]}" = "Existing pre-commit script does not appear to be sh/bash" ]
  run grep Existing_hook_file_content $hookfile
  [ "$status" -eq 0 ]
  run grep GITPROTECT_branch $hookfile
  [ "$status" -eq 1 ]
}
