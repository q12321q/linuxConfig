#!/bin/bash
ln -s -f ./dev/linuxConfig/config/.tmux.conf ~/.tmux.conf
ln -s -f ./dev/linuxConfig/config/.gdbinit ~/.gdbinit
ln -s -f ./dev/linuxConfig/config/.bashrc ~/.bashrc
ln -s -f ./dev/linuxConfig/config/.zshrc ~/.zshrc
mkdir -p ~/.config/termite
ln -s -f ../../dev/linuxConfig/config/.config/termite/config ~/.config/termite/config
