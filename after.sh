#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.


# If you're not quite ready for the latest Node.js version,
# uncomment these lines to roll back to a previous version

# Remove current Node.js version:
#sudo apt-get -y purge nodejs
#sudo rm -rf /usr/lib/node_modules/npm/lib
#sudo rm -rf //etc/apt/sources.list.d/nodesource.list

# Install Node.js Version desired (i.e. v13)
# More info: https://github.com/nodesource/distributions/blob/master/README.md#debinstall
#curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
#sudo apt-get install -y nodejs

timedatectl set-timezone America/Toronto

sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update

sudo apt-get install -y python2 tmux stow ripgrep \
  ninja-build gettext libtool git \
  libtool-bin autoconf automake \
  cmake g++ pkg-config unzip curl doxygen

# Add github.com and gitlab.com to known hosts
if [ ! -f "/home/vagrant/.ssh/known_hosts" ]; then
  echo "Add github and gitlab to known hosts"
  ssh-keyscan github.com >> ~/.ssh/known_hosts
  ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
else
  echo "SSH known hosts files already exists, skip"
fi

# Switch to ZSH
echo "Switch default shell to zsh"
sudo chsh -s $(which zsh) vagrant

# Create .local/bin directory if it doesn't exist
[ -d "home/vagrant/.local/bin" ] && "Local 'bin' folder already exists. Skipping step" || mkdir /home/vagrant/.local/bin

# Install TPM
if [ ! -d "home/vagrant/.tmux/plugins/tpm" ]; then
  echo "Installing Tmux TPM"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "Tmux TPM already installed"
fi

# Install .config files
if [ ! -d "/home/vagrant/.dot-files" ]; then
  echo "Installing dot files"
  git clone git@github.com:samiramer/dot-files-mac.git /home/vagrant/.dot-files
  sh -c "cd /home/vagrant/.dot-files; ./install.sh"
else
  echo "Dot files already exists, skipping step"
fi

# Install node version manager (nvm)
if [ ! -d "/home/vagrant/.nvm" ]; then
  echo "Install nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
else
  echo "Nvm is already installed, skipping step"
fi

# Install neovim
if [ ! -f "/home/vagrant/.local/nvim/bin/nvim" ]; then
  echo "Installing latest neovim release"
  git clone https://github.com/neovim/neovim
  cd neovim
  git checkout stable
  rm -r build/  # clear the CMake cache
  make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local/nvim" CMAKE_BUILD_TYPE=Release
  make install
  cd /home/vagrant
  rm -rf neovim
else
  echo "Neovim binary is already installed, skipping step"
fi

# Install neovim config files
if [ ! -d "/home/vagrant/.config/nvim" ]; then
  echo "Installing neovim config files"
  git clone git@github.com:samiramer/neovim-config.git /home/vagrant/.config/nvim
else
  echo "Neovim config files already exists, skipping step"
fi

# Install lazygit
if [ ! -f "/home/vagrant/.local/bin/lazygit" ]; then
  echo "Installing lazygit"
  wget https://github.com/jesseduffield/lazygit/releases/download/v0.34/lazygit_0.34_Linux_arm64.tar.gz
  tar -xf lazygit_0.34_Linux_arm64.tar.gz
  mv lazygit /home/vagrant/.local/bin/lazygit
  rm lazygit_0.34_Linux_arm64.tar.gz
else
  echo "Lazygit already installed, skipping step"
fi

# Install fzf
if [ ! -f "/home/vagrant/.local/bin/fzf" ]; then
  echo "Installing fzf"
  wget https://github.com/junegunn/fzf/releases/download/0.34.0/fzf-0.34.0-linux_arm64.tar.gz -O - | tar -xz -C ~/.local/bin/
else
  echo "fzf is already installed, skipping step"
fi

# Linux has a file watching limit that node can easily hit when running a watcher
# https://github.com/guard/listen/blob/master/README.md#increasing-the-amount-of-inotify-watchers
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

