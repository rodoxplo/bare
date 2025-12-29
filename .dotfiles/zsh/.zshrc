# ~/.zshrc — Modular & Clean for Starship + WezTerm

# ────────────────────────────────
# 🍺 Homebrew Env
# ────────────────────────────────
#eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man:$MANPATH"
export INFOPATH="/opt/homebrew/share/info:$INFOPATH"


# ────────────────────────────────
# ⚡ Fast completions (antes de OMZ)
# ────────────────────────────────
export ZSH_DISABLE_COMPFIX=true

autoload -Uz compinit

export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZSH_COMPDUMP:h}"

# Usa cache confiable (-C) para evitar compaudit + regeneraciones pesadas
if [[ -f "$ZSH_COMPDUMP" ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi

# Evita que Oh My Zsh ejecute compinit otra vez
compinit() { return 0 }

# ────────────────────────────────
# ⚙️ Oh My Zsh Setup
# ────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
# OMZ: no auto-update en el arranque (evita check_for_upgrade/handle_update)
zstyle ':omz:update' mode disabled
export DISABLE_AUTO_UPDATE="true"
export DISABLE_UPDATE_PROMPT="true"

# OMZ: reduce overhead de compaudit/compfix
export ZSH_DISABLE_COMPFIX=true

plugins=(
  git
  command-not-found
  zoxide
  thefuck
)

# Evitar que OMZ haga compinit; lo hacemos nosotros en deferred
skip_global_compinit=1

source $ZSH/oh-my-zsh.sh

# ────────────────────────────────
# 🌟 Prompt (Starship)
# ────────────────────────────────
eval "$(starship init zsh)"

# ✅ Fix path for SwiftBar
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

LOGFILE="$HOME/Library/Logs/brew_update_history.log"
# ... rest of script

# ────────────────────────────────
# 🧭 PATH Configuration
# ────────────────────────────────
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$HOME/.config/tmux/plugins/tmuxifier/bin:$HOME/.npm-global/bin:/opt/homebrew/opt/libtool/libexec/gnubin:/opt/homebrew/opt/python@3/libexec/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

## ────────────────────────────────
# 💎 PATH Gems
# ────────────────────────────────
export GEM_HOME="$HOME/.gem/ruby/3.4.0"
export PATH="$HOME/.gem/ruby/3.4.0/bin:$PATH"

# ────────────────────────────────
# ✍️ Editor Preferences
# ────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ────────────────────────────────
# 💬 Shell Enhancers
# ────────────────────────────────
eval "$(thefuck --alias)"
alias fk="fuck"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# ────────────────────────────────
# 🌈 Syntax Highlighting Theme
# ────────────────────────────────
source "$HOME/.config/catppuccin/zsh-syntax-highlighting/themes/catppuccin_frappe-zsh-syntax-highlighting.zsh"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# ────────────────────────────────
# 🧠 Completion Tweaks
# ────────────────────────────────
#autoload -Uz compinit && compinit
zstyle ':completion:*' use-cache yes
zstyle ':completion::complete:*' cache-path ~/.zcompcache
zstyle ':completion:*' menu select

# ────────────────────────────────
# 📜 History Settings
# ────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history
setopt hist_ignore_all_dups
setopt inc_append_history

# ────────────────────────────────
# 🎨 FZF Colors
# ────────────────────────────────
export FZF_DEFAULT_OPTS=" \
--color=bg+:,bg:,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d \
--multi"

# ────────────────────────────────
# ⌨️ Vi Mode Prompt Indicator
# ────────────────────────────────
function zle-keymap-select {
  RPS1="%{[36m%}❮ %{[0m%}"
  zle reset-prompt
}
zle -N zle-keymap-select

# ────────────────────────────────
# 🪟 WezTerm Title
# ────────────────────────────────
if [[ "$TERM_PROGRAM" == "WezTerm" && "$WEZDROP" == "true" ]]; then
  precmd() {
    echo -ne "\033]0;WezDrop\007"
  }
fi
DISABLE_AUTO_TITLE="true"

# ────────────────────────────────
# 📂 Aliases Loader
# ────────────────────────────────
[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

# ────────────────────────────────
# 📁 Yazi Navigation Helpers
# ────────────────────────────────
function yy() {
	local tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function fcd() {
  local dir
  dir=$(yazi --cwd-file=/tmp/yazi_dir | tail -n 1)
  if [[ -d "$dir" ]]; then
    cd "$dir"
  fi
}

# ────────────────────────────────
# 📁 Eza translate
# ────────────────────────────────
unalias ls 2>/dev/null

ls() {
  local flags="$*"
  local args=()
  
  # Defaults
  local long=false
  local all=false
  local human=false
  local reverse=false
  local sort=""
  local tree=false

  # Match compound flags like -lart, -lhtrS, etc.
  [[ $flags == *"l"* ]] && long=true
  [[ $flags == *"a"* ]] && all=true
  [[ $flags == *"h"* ]] && human=true
  [[ $flags == *"r"* ]] && reverse=false
  [[ $flags == *"t"* ]] && sort="modified"
  [[ $flags == *"S"* ]] && sort="size"
  [[ $flags == *"U"* ]] && sort="accessed"
  [[ $flags == *"c"* ]] && sort="created"
  [[ $flags == *"C"* ]] && sort="changed"
  [[ $flags == *"T"* ]] && tree=true

  # Build eza args
  $long && args+=("-l")
  $all && args+=("-a")
  $human && args+=("-h")
  [[ -n $sort ]] && args+=("-s" "$sort")
  $reverse && args+=("-r")
  $tree && args+=("--tree" "--level=2")

  # Add eza extras
  args+=("--group-directories-first" "--icons")

  command eza "${args[@]}"
}


# ────────────────────────────────
# 🛑 Trap and Silent Failures
# ────────────────────────────────
TRAPZERR() { return 0 }
precmd() { :; }
export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"
