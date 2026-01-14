# Adding the line to suppress the instant prompt warning
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
alias windoc="cd /mnt/c/Users/jmundt/Documents"
alias insightsproduction="cd ~/work/projects/insights_prod/intermountain-insights"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$PATH:$HOME/bin:/opt/nvim-linux-x86_64/bin"
export PATH=$PATH:/usr/local/go/bin
# export PATH="$PATH:$HOME/go/bin
#
export EDITOR=nvim
export VISUAL=nvim

# opencode
export PATH=/home/justin/.opencode/bin:$PATH

# Load secrets (API keys, etc.) from ~/.secrets if it exists
# See .secrets.example for required variables
[[ -f ~/.secrets ]] && source ~/.secrets


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
ZSH_THEME="agnoster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"
#
#
#

convert() {
  ffmpeg -i "$1.m4a" -codec:a libmp3lame -q:a 2 "$1.mp3"
}


music_abc () {
  local base="${1%.*}"
  local sf2="/usr/share/sounds/sf2/FluidR3_GM.sf2"

  # Run abc2midi and show messages
  local out
  out="$(abc2midi "${base}.abc" -o "${base}.mid" 2>&1)"
  printf '%s\n' "$out" >&2


  # Fail if abc2midi complained or MIDI is tiny
  if [[ "$out" == *"No valid K:"* ]] || [[ ! -s "${base}.mid" || $(wc -c < "${base}.mid") -lt 500 ]]; then
    echo "abc2midi did not parse the tune (check K: / formatting). Aborting." >&2
    return 1
  fi

  # Render + encode
  [[ -f "$sf2" ]] || { echo "SoundFont missing: $sf2" >&2; return 1; }

  fluidsynth -ni -T wav -r 44100 -g 1.0 \
    -F "${base}.wav" \
    "$sf2" \
    "${base}.mid" || return 1

  ffmpeg -y -i "${base}.wav" -codec:a libmp3lame -q:a 2 "${base}.mp3" || return 1
}

take_audio() {
  # Usage: take_audio "bach" [N=100] [OUTDIR=./audio]
  local q="$1"
  local n="${2:-100}"
  local outdir="${3:-./audio}"
  mkdir -p "$outdir"

  yt-dlp \
    -x --audio-format mp3 --audio-quality 0 \
    --embed-thumbnail --embed-metadata --embed-chapters \
    --ignore-errors --continue -N 4 \
    --download-archive "$outdir/.downloaded.txt" \
    -o "$outdir/%(uploader)s - %(title)s [%(id)s].%(ext)s" \
    "ytsearch${n}:${q}"
}

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
#
#
# Insights projcet quick aliases

function flask_insights_project_env() {
    # Path to your virtual environment
    local venv_path="$HOME/.virtualenvs/.insightsvenv"

    # Check if the virtual environment is already activated
    if [[ "$VIRTUAL_ENV" != "$venv_path" ]]; then
      # Deactivate any currently active virtual environment
      if type deactivate >/dev/null 2>&1; then
          deactivate
      fi
    # Activate the target virtual env
        source "$venv_path/bin/activate"
    fi

    # Navigate to your project directory
    cd ~/work/projects/insights_prod/intermountain-insights/flask
}


alias flaskinsights='flask_insights_project_env'

source ~/.zsh_profile
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.local/bin:$PATH"
