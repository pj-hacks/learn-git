#!/bin/bash

# Update and upgrade Termux packages
echo "Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Install Zsh
echo "Installing Zsh..."
pkg install zsh -y

# Verify Zsh installation
if ! command -v zsh &> /dev/null; then
  echo "Zsh installation failed. Exiting..."
  exit 1
fi

# Change default shell to Zsh
echo "Changing default shell to Zsh..."
chsh -s zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set default theme and plugins in ~/.zshrc
echo "Configuring Oh My Zsh..."

cat << 'EOF' > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"

# Set Zsh theme
ZSH_THEME="agnoster"  # Change to your preferred theme

# Enable plugins
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-history-substring-search
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='ls -la'
alias gs='git status'
alias gl='git log'

# Custom prompt
PROMPT='%F{cyan}%n@%m%f %F{yellow}%1~%f %# '

# Path customizations (optional)
export PATH="$HOME/bin:$PATH"
EOF

# Reload Zsh configuration
echo "Reloading Zsh configuration..."
source ~/.zshrc

# Install plugins
echo "Installing plugins..."

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Install zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search.git $ZSH_CUSTOM/plugins/zsh-history-substring-search

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Configure Powerlevel10k theme
sed -i 's/ZSH_THEME="agnoster"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Final message
echo "Oh My Zsh setup complete!"
echo "Restart Termux or run 'zsh' to use your new shell."
