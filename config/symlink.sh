#!/bin/bash
GIT_CONFIG='~/dev/linuxConfig/config'
ln -s -f $GIT_CONFIG/.tmux.conf ~/.tmux.conf
ln -s -f $GIT_CONFIG/.gdbinit ~/.gdbinit
ln -s -f $GIT_CONFIG/.bashrc ~/.bashrc
ln -s -f $GIT_CONFIG/.zshrc ~/.zshrc
if [ ! -d ~/.config/termite ]
then
  mkdir -p ~/.config/termite
if
ln -s -f $GIT_CONFIG/.config/termite/config ~/.config/termite/config
if [! -d ~/.oh-my-zsh/themes ]
then
  mkdir -p ~/.oh-my-zsh/themes
if
ln -s -f $GIT_CONFIG/.oh-my-zsh/themes/q12321q.zsh-theme ~/.oh-my-zsh/themes/q12321q.zsh-theme
