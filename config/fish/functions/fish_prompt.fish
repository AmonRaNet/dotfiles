#!/usr/bin/fish

set fish_git_dirty_color red
set fish_git_not_dirty_color green

function parse_git_branch
  set -l branch (git branch 2> /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/\1/')
  set -l git_diff (git diff)

  if test -n "$git_diff"
    echo (set_color -o D0D0D0 -b $fish_git_dirty_color)$branch(set_color normal)
  else
    echo (set_color -o D0D0D0 -b $fish_git_not_dirty_color)$branch(set_color normal)
  end
end

function fish_prompt
  set -l git_dir (git rev-parse --git-dir 2> /dev/null)
  if test -n "$git_dir"
    printf '%s %s%s%s> ' (parse_git_branch) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  else
    printf 'fish %s%s%s> ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
  end
end
