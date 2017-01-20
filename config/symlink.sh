#!/bin/bash
GIT_CONFIG="$HOME/dev/linuxConfig/config"
ln -s -f $GIT_CONFIG/.tmux.conf ~/.tmux.conf
ln -s -f $GIT_CONFIG/.gdbinit ~/.gdbinit
ln -s -f $GIT_CONFIG/.bashrc ~/.bashrc

if [ ! -d ~/.config/termite ]
then
  mkdir -p ~/.config/termite
fi
ln -s -f $GIT_CONFIG/.config/termite/config ~/.config/termite/config

# ZSH shell
ln -s -f $GIT_CONFIG/.zshrc ~/.zshrc
if [ ! -d ~/.oh-my-zsh/themes ]
then
  mkdir -p ~/.oh-my-zsh/themes
fi
ln -s -f $GIT_CONFIG/.oh-my-zsh/themes/q12321q.zsh-theme ~/.oh-my-zsh/themes/q12321q.zsh-theme

# fish shell
if [ ! -d ~/.config ]
then
  mkdir -p ~/.config
fi
ln -s -f $GIT_CONFIG/.config/omf ~/.config/omf
