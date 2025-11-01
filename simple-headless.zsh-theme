# filepath: /home/david/Dev/NixOS/simple-headless.zsh-theme
# Custom minimal theme for headless servers

# Virtual environment info
venv_prompt_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%{$fg[green]%}($(basename $VIRTUAL_ENV))%{$reset_color%} "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "%{$fg[green]%}(conda:$CONDA_DEFAULT_ENV)%{$reset_color%} "
  fi
}

# Smart path shortening
smart_pwd() {
  local pwd_length=${#PWD}
  if [[ $pwd_length -gt 50 ]]; then
    echo "%{$fg[magenta]%}$(print -P "%2~")%{$reset_color%}"
  else
    echo "%{$fg[magenta]%}%~%{$reset_color%}"
  fi
}

setopt PROMPT_SUBST
PROMPT='$(venv_prompt_info)%{$fg[white]%}[%{$reset_color%}%{$fg[green]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[blue]%}%m%{$reset_color%}%{$fg[white]%}: %{$reset_color%}$(smart_pwd)%{$fg[white]%}]%{$reset_color%}$(git_prompt_info) '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""