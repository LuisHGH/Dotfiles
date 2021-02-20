# LuisHGH fish configuration.


# General settings (-x exports)
set -x EDITOR "nvim"
set -x TERM "kitty"

# Sources secrets and tokens
source $HOME/.secrets.sh

# Lutris
set -xg VK_ICD_FILENAMES /usr/share/vulkan/icd.d/intel_icd.x86_64.json

# Export .local/bin to PATH
set -xg PATH $HOME/.local/bin $PATH

# Export .yarn/bin to PATH
set -xg PATH $HOME/.yarn/bin $PATH

# Doom Emacs
set -xg PATH $HOME/.emacs.d/bin $PATH

# dotfiles repo
alias dotrepo="git --git-dir=Documents/dotfiles --work-tree=/home/luishgh/"

# td-cli config path
set -xg TD_CLI_HOME "/home/luishgh/.config/td-cli/"

#

# Starship prompt
starship init fish | source