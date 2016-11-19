#!/usr/bin/env bash

sudo apt-get install libtool \
                     libtool-bin \
                     autoconf \
                     automake \
                     make \
                     cmake \
                     g++ \
                     pkg-config \
                     unzip \
                     xsel \
		     python \
		     python-pip \
		     python-dev \
		     python3 \
		     python3-pip \
		     python3-dev

if [ -d "$HOME/dev" ] ; then
  mkdir ~/dev
fi

cd ~/dev
git clone https://github.com/neovim/neovim
cd neovim
make
sudo make install
sudo pip install neovim
sudo pip3 install neovim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
sudo update-alternatives --config editor
