sudo apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

if [ -d "$HOME/dev" ] ; then
  mkdir ~/dev
fi

cd ~/dev
git clone https://github.com/neovim/neovim
cd neovim
make
sudo make install
