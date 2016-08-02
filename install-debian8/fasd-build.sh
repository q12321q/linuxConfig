#!/usr/bin/env bash

if [ -d "$HOME/dev" ] ; then
  mkdir ~/dev
fi

cd ~/dev
git clone https://github.com/clvv/fasd
cd fasd
PREFIX=$HOME/.local make install

if [ -d "$HOME/.zshrc" ] ; then
  echo eval \"\$\(fasd --init posix-alias zsh-hook\)\" >> $HOME/.zshrc
fi
