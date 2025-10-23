# shellcheck shell=bash disable=SC2155

alias g='git'
alias ga='git add'
alias gb='git branch-fzf'
alias gc='git commit'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gcol='git checkout-latest'
alias gd='git diff'
alias gdw='git diff --word-diff=color --word-diff-regex=.'
alias gf='git fetch'
alias gg!='gg --amend --no-edit'
alias gl='git log'
alias gpl='git pull'
alias gps='git push'
alias gr='git rebase'
alias grh='git reset HEAD'
alias gs='git status'

alias diff='gd --no-index' # Same as diff -u --color but run through less

gg() {
  # Usage: gg [-A] [<git commit options>] [bare message...]
  # Commits everything if -A or nothing staged
  # https://kagamine.dev/en/gg-faster-git-commits/
  local root opts=() all= unstaged_changes
  root=$(git rev-parse --show-toplevel) || return
  while [[ ${1::1} == '-' ]]; do
    if [[ $1 == '--' ]]; then
      shift; break
    elif [[ $1 == '-A' ]]; then
      all=1; shift
    else
      opts+=("$1"); shift
    fi
  done
  if (( $# > 0 )); then
    opts+=(-m "$*")
  fi
  if [[ $all ]] || git diff --cached --quiet; then
    git add -A || return
  else
    # Check if only some changes are staged
    unstaged_changes=$(git diff-files && git ls-files -o --exclude-standard "$root") || return
    [[ $unstaged_changes ]] && echo 'Committing only staged changes.'
  fi
  git commit "${opts[@]}" && sweetroll skill Committing
}

fus() {
  # https://kagamine.dev/en/fus-ro-dah/
  if [[ $* =~ ^ro\ dah ]]; then
    git nuke && sweetroll play fusrodah
  else
    ( root=$(git rev-parse --show-toplevel) && cd "$root" && # git clean operates in current dir
      git reset --hard && git clean -fd && sweetroll play fus )
  fi
  sweetroll $?
}

fzf-commit() {
  git log --pretty='%H %C(auto)%h%(decorate) %s' --no-show-signature --color=always |
    fzf --ansi --with-nth=2.. --no-sort --layout=reverse-list --no-hscroll |
    awk '{ print $1 }'
}

fixup() { # [<commit>]
  local commit=${1:-$(fzf-commit)}
  if [[ ! $commit ]]; then
    return 1
  fi
  git merge-base --is-ancestor "$commit" HEAD || {
    (( $? == 1 )) && echo 'Commit is not an ancestor of HEAD' >&2
    return 1
  }
  gg fixup! "$commit" && gr -i --committer-date-is-author-date "$commit"~
}

# shellcheck disable=SC1091
if source /usr/share/bash-completion/completions/git 2>/dev/null; then
  __git_complete g __git_main
  __git_complete gb _git_branch
  __git_complete gco _git_checkout
  __git_complete gcol _git_checkout
  __git_complete gd _git_diff
  __git_complete gg _git_commit
  __git_complete gl _git_log
  __git_complete gpl _git_pull
  __git_complete gr _git_rebase
fi
