Git Protect
===========

Protect your local branches from yourself.

Introduction
------------

Sometimes you're working on a project which uses git hosting with protected
branches that you can't push to, because you're expected to use feature
branching and pull requests.

And sometimes you forget that and make commits to your local branches that have
protected remotes.

Using `git protect` you can avoid this!


Installation
------------

Put `git-protect` somewhere on your PATH. Git is smart enough to figure out the
rest.


Usage
-----

From your git repo directory, just run:

```
git protect <branchname>
```

Now when you try to commit to that branch you will see "<branch> is protected"

Run `git protect -h` for more options
