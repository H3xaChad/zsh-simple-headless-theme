# Custom minimal theme for headless servers

# Virtual environment info
venv_prompt_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%{$fg[green]%}($(basename $VIRTUAL_ENV))%{$reset_color%}"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "%{$fg[green]%}(conda: $CONDA_DEFAULT_ENV)%{$reset_color%}"
  fi
}

# Node.js project info
node_prompt_info() {
  if [[ -f "package.json" || -f "node_modules" ]]; then
    local node_version=""
    if command -v node >/dev/null 2>&1; then
      node_version=$(node --version 2>/dev/null | sed 's/^v//')
      echo " %{$fg[yellow]%}(node: $node_version)%{$reset_color%}"
    else
      echo " %{$fg[yellow]%}(node: not found)%{$reset_color%}"
    fi
  fi
}

# Powerlevel10k-style path shortening
smart_pwd() {
  local path="$PWD"
  
  # Replace home with ~
  [[ "$path" == "$HOME"* ]] && path="~${path#$HOME}"
  
  # Return if path is short enough or is just home/root
  [[ ${#path} -le 42 || "$path" == "~" || "$path" == "/" ]] && {
    echo "%{$fg[magenta]%}$path%{$reset_color%}"
    return
  }
  
  # Split into array, removing empty elements
  local -a parts=("${(@s:/:)path}")
  parts=("${(@)parts:#}")
  
  # If only 1-2 parts, return as is
  [[ ${#parts} -le 2 ]] && {
    echo "%{$fg[magenta]%}$path%{$reset_color%}"
    return
  }
  
  local result=""
  local current_length=${#path}
  
  # Shorten from longest to shortest, but skip the last directory (current project)
  for (( i=1; i<${#parts}; i++ )); do
    [[ $current_length -le 42 ]] && break
    
    # Find longest directory that's not the last one and not already shortened
    local max_len=0
    local max_idx=0
    for (( j=1; j<${#parts}; j++ )); do
      if [[ ${#parts[j]} -gt $max_len && ${#parts[j]} -gt 2 ]]; then
        max_len=${#parts[j]}
        max_idx=$j
      fi
    done
    
    # Break if nothing left to shorten
    [[ $max_len -le 2 ]] && break
    
    # Shorten the longest directory
    current_length=$((current_length - ${#parts[max_idx]} + 2))
    parts[max_idx]="${parts[max_idx]:0:2}"
  done
  
  # Rebuild path with colors
  if [[ "$path" == "~"* ]]; then
    result="%{$fg[magenta]%}~%{$reset_color%}"
    for (( i=2; i<=${#parts}; i++ )); do
      if [[ ${#parts[i]} -eq 2 && ${#parts[i]} -lt ${#${parts[i]}} ]]; then
        # This is a shortened segment - make it gray
        result="$result/%{$fg[black]%}${parts[i]}%{$reset_color%}"
      else
        # Full segment - keep magenta
        result="$result/%{$fg[magenta]%}${parts[i]}%{$reset_color%}"
      fi
    done
  else
    result=""
    for (( i=1; i<=${#parts}; i++ )); do
      if [[ ${#parts[i]} -eq 2 && $i -lt ${#parts} ]]; then
        # This might be a shortened segment - make it gray
        result="$result/%{$fg[black]%}${parts[i]}%{$reset_color%}"
      else
        # Full segment - keep magenta
        result="$result/%{$fg[magenta]%}${parts[i]}%{$reset_color%}"
      fi
    done
  fi
  
  echo "$result"
}

setopt PROMPT_SUBST
PROMPT='%{$fg[white]%}[%{$reset_color%}%{$fg[green]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[blue]%}%m%{$reset_color%}%{$fg[white]%}: %{$reset_color%}$(smart_pwd)%{$fg[white]%}]%{$reset_color%} '
RPROMPT='$(venv_prompt_info)$(node_prompt_info)$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""