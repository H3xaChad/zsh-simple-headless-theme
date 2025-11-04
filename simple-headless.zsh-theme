# Minimal zsh prompt only using ascii

export VIRTUAL_ENV_DISABLE_PROMPT=1 # Disable default venv prompt

# Virtual env info
venv_prompt_info() {
    if [[ -n $VIRTUAL_ENV ]]; then
        local name=${VIRTUAL_ENV:h:t}
        echo "%{$fg[green]%}(venv: ${name})%{$reset_color%}"
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        echo "%{$fg[green]%}(venv: ${CONDA_DEFAULT_ENV})%{$reset_color%}"
    fi
}

# Node project info
node_prompt_info() {
    if [[ -f package.json || -d node_modules ]]; then
        if command -v node >/dev/null 2>&1; then
            local nv=$(node -v 2>/dev/null)
            nv=${nv#v}
            echo "%{$fg[yellow]%}(node: ${nv})%{$reset_color%}"
        else
            echo "%{$fg[yellow]%}(node: not found)%{$reset_color%}"
        fi
    fi
}

# Smart working-directory shortening
smart_pwd() {
    local max_len=50
    local -a prefixes
    prefixes=(
        "/media/ssd/Library"
    )
    local path=$PWD

    # Replace $HOME with ~
    if [[ $path == $HOME/* || $path == $HOME ]]; then
        path="~${path#$HOME}"
    fi

    for p in "${prefixes[@]}"; do
        if [[ $path == $p/* ]]; then
            path=${path#$p}
            [[ $path != /* ]] && path="/${path}"
            break
        fi
    done

    local display_path="$path"

    # When short enough, return
    if (( ${#display_path} <= max_len )); then
        echo "%{$fg[magenta]%}${display_path}%{$reset_color%}"
        return
    fi

    # Split into segments
    local lead=""
    if [[ $display_path == "~/"* ]]; then
        lead="~"
        display_path=${display_path#~/}
    elif [[ $display_path == /* ]]; then
        lead="/"
        display_path=${display_path#/}
    fi

    local -a parts
    parts=("${(s:/:)display_path}")
    local -a original_parts
    original_parts=("${parts[@]}")

    # If only 1-2 parts left, return shortened by truncating middle
    if (( ${#parts} <= 2 )); then
        local out="${lead}$(printf "/%s" "${parts[@]}")"
        echo "%{$fg[magenta]%}${out}%{$reset_color%}"
        return
    fi

    # Iteratively shorten the longest non-last directory
    local iter=0
    local cur_display
    local i
    while true; do
        ((iter++))
        # build plain candidate (no color escapes) to measure length
        cur_display="$lead"
        if [[ -n $lead && ${#parts[@]} -gt 0 ]]; then
            cur_display+="$(printf "/%s" "${parts[@]}")"
        else
            cur_display+="$(printf "%s" "${parts[1]}")"
            for ((i=2; i<=${#parts}; i++)); do
                cur_display+="/${parts[i]}"
            done
        fi

        if (( ${#cur_display} <= max_len )); then
            break
        fi

        # Find index of the longest directory excluding the last element
        local max_len_part=0
        local max_idx=0
        for ((i=1; i<${#parts}; i++)); do
            local l=${#parts[i]}
            if (( l > max_len_part )); then
                max_len_part=$l
                max_idx=$i
            fi
        done

        # nothing sensible to shorten (all small) or reached max iteration -> stop
        if (( max_len_part <= 4 || iter > 10 )); then
            break
        fi

        # shorten element to its first 2 chars
        parts[$max_idx]="${parts[$max_idx]:0:2}"
    done

    # Rebuild colored output, highlighting shortened parts in bold
    local result="%{$fg[magenta]%}"
    if [[ -n $lead ]]; then
        result+="${lead}"
    fi
    for ((i=1; i<=${#parts}; i++)); do
        local p="${parts[i]}"
        local orig="${original_parts[i]}"
        if [[ ${#p} -lt ${#orig} ]]; then
            result+="/%{$fg_bold[magenta]%}${p}%{$fg[magenta]%}"
        else
            result+="/${p}"
        fi
    done
    result+="%{$reset_color%}"
    echo "${result}"
}

# Git info for rprompt
custom_git_prompt() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        local git_status
        git_status=$(git status --porcelain 2>/dev/null || true)

        local stats=""
        if [[ -n $git_status ]]; then
            local added modified deleted untracked
            added=$(echo "$git_status" | grep -c '^A' || true)
            modified=$(echo "$git_status" | grep -c '^[M ]M\|^M ' || true)
            deleted=$(echo "$git_status" | grep -c '^[D ]D\|^D ' || true)
            untracked=$(echo "$git_status" | grep -c '^??' || true)
            
            [[ $added -gt 0 ]] && stats+=" +${added}"
            [[ $deleted -gt 0 ]] && stats+=" -${deleted}"
            [[ $modified -gt 0 ]] && stats+=" *${modified}"
            [[ $untracked -gt 0 ]] && stats+=" ?${untracked}"
            
            echo "%{$fg[white]%}(${branch}${stats})%{$reset_color%}"
        else
            echo "%{$fg[white]%}(${branch})%{$reset_color%}"
        fi
    fi
}

# Prompt setup
setopt PROMPT_SUBST

PROMPT='%{$fg[white]%}[%{$reset_color%}%{$fg[green]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[blue]%}%m%{$reset_color%}%{$fg[white]%}: %{$reset_color%}$(smart_pwd)%{$fg[white]%}]%{$reset_color%} '
RPROMPT='$(custom_git_prompt) $(venv_prompt_info) $(node_prompt_info)'

# zsh-syntax-highlighting colors
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue'
