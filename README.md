Git Protect
===========

Protect your local branches.

Introduction
------------

Sometimes you're working on a project which uses git hosting with protected
branches that you can't push to, because you're expected to use feature
branching and pull requests.

And sometimes you forget that and make commits to your local branches that have
protected remotes.

Using `git protect` you can avoid this!

Usage
-----

From your git repo directory, just run:

```
git protect <branchname>
```

That's it!

Also "unprotect" (endanger?) a branch with:

```
git protect -e <branchname>
```

How It Works
------------

TBC
