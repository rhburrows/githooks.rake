namespace :githooks do
  HOOKS = {
    # :applypatch_msg => "applypatch-msg",
    # :pre_applypatch => "pre-applypatch",
    # :post_applypatch => "post-applypatch",
    :pre_commit => "pre-commit",
    # :prepare_commit_msg => "prepare-commit-msg",
    # :commit_msg => "commit-msg",
    :post_commit => "post-commit",
    # :pre_rebase => "pre-rebase",
    :post_checkout => "post-checkout",
    :post_merge => "post-merge",
    # :pre_receive => "pre-receive",
    # :update => "update",
    # :post_receive => "post-receive",
    # :post_update => "post-update",
    # :pre_auto_gc => "pre-auto-gc",
    # :post_rewrite => "pst-rewrite"
  }

  namespace :install do
    HOOKS.each_pair do |key, value|
      desc "Install #{value} githooks"
      task key do
        require 'erb'

        script_dir = ENV['DIR'] || "script/git"
        File.open(".git/hooks/#{value}", "w") do |f|
          template = ERB.new(TEMPLATES[key])
          f.write(template.result(binding))
        end
        system("chmod a+x .git/hooks/#{value}")
      end
    end

    task :default => HOOKS.keys
  end

  desc "Install all githooks"
  task :install => "install:default"

  namespace :run do
    HOOKS.each_pair do |key, value|
      desc "Run #{value} githooks"
      task key do
        system(".git/hooks/#{value}")
      end
    end
  end
end

TEMPLATES = {}
#===========================================================================
# GIT HOOK TEMPLATES BELOW HERE
#===========================================================================
TEMPLATES[:post_checkout] = <<-END
#!/bin/sh
#
# A post-checkout hook that runs all post-checkout hooks in
# <%= script_dir %>/post-checkout

# only run if the hooks directory is there
test -d <%= script_dir %>/post-checkout || exit 0

for HOOK in `ls <%= script_dir %>/post-checkout`; do
  <%= script_dir %>/post-checkout/$HOOK
done
END

TEMPLATES[:post_commit] = <<-END
#!/bin/sh
#
# A post-commit hook that runs all the post-commit hooks in
# <%= script_dir %>/post-commit

# only run if the hook directory is there
test -d <%= script_dir %>/post-commit || exit 0

for HOOK in `ls <%= script_dir %>/post-commit`; do
  <%= script_dir %>/post-commit/$HOOK
done
END

TEMPLATES[:post_merge] = <<-END
#!/bin/sh
#
# A post-merge hook that runs all post-merge hooks in
# <%= script_dir %>/post-merge

# only run if the hook directory is there
test -d <%= script_dir %>/post-merge || exit 0

for HOOK in `ls <%= script_dir %>/post-merge` ; do
  <%= script_dir %>/post-merge/$HOOK
done
END

TEMPLATES[:pre_commit] = <<-END
#!/bin/sh
#
# A pre-commit hook that runs all the pre-commit hooks in
# <%= script_dir %>/pre-commit in order based on their number prefix
#
# Scripts in that directory should be named like
# 10-print-changed-files.rb
# Where 10 is used to determine the order run in

# only run if the hook directory is there
test -d <%= script_dir %>/pre-commit || exit 0

status=0
for HOOK in  `ls <%= script_dir %>/pre-commit` ; do
  if ! <%= script_dir %>/pre-commit/$HOOK; then
    status=1
  fi
done

test $status -eq 1 && {
  echo
  echo "Precommit hooks failed."
}

exit $status
END
