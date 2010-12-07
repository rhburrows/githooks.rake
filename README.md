# githooks.rake

Rake tasks for sharing git hooks

## Description

githooks are scripts that git calls at certain points during its
execution. For example you could have a script that rebuilds your
ctags file everytime you switch branches. Traditionally these scripts
are contained in the git directory (typically `.git`) so they are not
easy to share across all copies of the project.

This is a collection of rake tasks to allow you to install githooks
that will trigger a collection of scripts within a directory that can
be committed to the repository.

At the moment it only has support for the following githooks, but the
remaining ones are coming:

 1. `pre-commit`
 2. `post-commit`
 3. `post-checkout`
 4. `post-merge`

## Installation

First make sure that githooks.rake is included into your `Rakefile`:

    load("path/to/githooks.rake")

Or if you are using Rails you can just copy the script into `lib/tasks`

Next install the hooks in the project:

    rake githooks:install

This command will install simple shell scripts that will call all the
corresponding scripts in `script/git/$HOOK_NAME` when the githook is
triggered. For example when the pre-commit hook is triggered the
installed script will run all executable files in the
`script/git/pre-commit` directory.

If you don't want to have your shared githook scripts installed in
`script/git` you can specify a different directory when running the
install command with the `DIR` environment variable:

    rake githooks:install DIR=hooks

Also, if you don't want to used shared scripts for all of the
githooks, you can install just the ones you are interested in with the
corresponding rake tasks:

    rake githooks:install:pre_commit
    rake githooks:install:post_commit

**Warning**: all of these tasks will override any scripts in
`$GIT_DIR/hooks` for the hook you are installing. If you have scripts
in place that you are currently using be sure to back them up *before*
running the install tasks.

## Usage

After installing the githooks with the rake tasks, git will call all
of the scripts in the `$HOOK_NAME` directory in the order they are
listed through `ls`. If your scripts must run in a specific order name
them accordingly.

For example if you want to ensure that the script `before.sh` runs
prior to `after.sh` consider naming them `1-before.sh` and
`2-after.sh`. Following a similar naming convention also makes it
apparent the order that the scripts will run if you have multiple of
them.

`githooks.rake` also provides tasks for executing the various hooks
that can be used to test out scripts that you are working on. For
example to execute all of the post-commit hooks you could run

    rake githooks:run:post_commit
