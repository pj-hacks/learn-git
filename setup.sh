#!/bin/bash

# Update and Upgrade
echo "Updating and upgrading Termux..."
pkg update -y && pkg upgrade -y

# Change repository to a reliable mirror
echo "Changing repository to a reliable mirror..."
termux-change-repo --force-mirror

# Install core packages
echo "Installing core development and utility packages..."
pkg install -y clang make cmake gdb git manpages build-essential \
               termux-api unzip wget curl zsh neovim tmux htop tree ncdu \
               figlet toilet ncurses-utils

# Install development-specific tools
echo "Installing additional tools for C development..."
pkg install -y cmocka universal-ctags valgrind

# Setup Zsh and Oh-My-Zsh
echo "Installing Zsh and Oh-My-Zsh..."
pkg install -y zsh
chsh -s zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Zsh plugins
echo "Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Configure Zsh plugins
echo "Configuring Zsh plugins..."
sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Configure Neovim
echo "Setting up Neovim..."
mkdir -p ~/.config/nvim
cat <<EOL > ~/.config/nvim/init.vim
call plug#begin('~/.vim/plugged')

" Syntax highlighting and linting
Plug 'dense-analysis/ale'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" File Explorer
Plug 'preservim/nerdtree'

" Status Line
Plug 'vim-airline/vim-airline'

call plug#end()

" General settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set cursorline
syntax on
filetype plugin indent on

" Keybindings
nmap <C-n> :NERDTreeToggle<CR>
EOL

# Install vim-plug and Neovim plugins
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall

# Configure Tmux
echo "Setting up Tmux..."
cat <<EOL > ~/.tmux.conf
set -g mouse on
bind | split-window -h
bind - split-window -v
EOL

# Create default C project structure
echo "Creating default project template..."
mkdir -p ~/CProjects/template/{src,include,build}
cat <<EOL > ~/CProjects/template/src/main.c
#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    return 0;
}
EOL
cat <<EOL > ~/CProjects/template/Makefile
CC = clang
CFLAGS = -I./include -Wall -Wextra -g
SRC = \$(wildcard src/*.c)
OBJ = \$(SRC:src/%.c=build/%.o)
TARGET = build/my_program

all: \$(TARGET)

\$(TARGET): \$(OBJ)
	\$(CC) -o \$@ \$^

build/%.o: src/%.c
	\$(CC) \$(CFLAGS) -c \$< -o \$@

clean:
	rm -rf build/*.o \$(TARGET)
EOL

# Add custom aliases and functions
echo "Adding custom aliases and functions..."
cat <<EOL >> ~/.zshrc

# Custom Aliases
alias ll='ls -la'
alias gs='git status'
alias mkcd='mkdir -p \$1 && cd \$1'
alias run='./build/my_program'
alias debug='gdb ./build/my_program'

# Function to create a new C project
function create_c_project() {
    mkdir -p \$1/src \$1/include \$1/build
    cp ~/CProjects/template/* \$1
    echo "C project \$1 created successfully."
}
EOL

# Show welcome banner
echo "Setting up a welcome banner..."
cat <<EOL >> ~/.zshrc
figlet -f slant "Welcome, Developer!"
EOL

# Clean up and finalize
echo "Setup complete! Restart Termux to apply all changes."
