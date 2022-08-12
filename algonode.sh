#!/bin/bash

if [[ $OSTYPE = 'darwin'* ]]; then
  echo "Identified MacOS"
  which -s brew
  if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    echo "brew was installed"
  fi

  brew update

  default_shell=`dscl . -read ~/ UserShell | sed 's/UserShell: //'`
  echo "DEFAULT SHELL: $default_shell"

  if [ "$default_shell" = "/bin/zsh" ]; then
    echo "Identified ZHS as default shell. Exporting variables to ~/.zshrc"
    printf "%s\n" "export ALGORAND_DATA=\"\$HOME/node/data\"" "export PATH=\"\$HOME/node:\$PATH\"" >> ~/.zshrc
  else
    echo "Identified bash as default shell. Exporting variables to ~/.bashrc"
    printf "%s\n" "export ALGORAND_DATA=\"\$HOME/node/data\"" "export PATH=\"\$HOME/node:\$PATH\"" >> ~/.bashrc
  fi
  export PATH="/usr/local/bin:$PATH"

  node -v
  if [[ $? != 0 ]] ; then
    echo "INSTALLING node"
    brew install node
  else
    echo "node was installed"
    node -v
    npm -v
  fi

  git --version
  if [[ $? != 0 ]] ; then
    echo "INSTALLING git"
    brew install git
  else
    echo "git was installed"
    git --version
  fi
else
  if [[ $OSTYPE = 'linux'* ]] ; then
    echo "Identified Linux"
    
    if [[ $(lsb_release -si) != "Ubuntu" ]]; then
      echo "ERROR: Identified distro is not Ubuntu: $(lsb_release -si). Aborting Installation"
      exit 1
    fi
    
    sudo apt-get update

    node -v
    if [[ $? != 0 ]] ; then
      echo "INSTALLING node"
      sudo apt-get install nodejs
    else
      echo "node was installed"
      node -v
    fi

    npm -v
    if [[ $? != 0 ]] ; then
      echo "INSTALLING npm"
      sudo apt-get install npm
    else
      echo "npm was installed"
      npm -v
    fi


    git --version
    if [[ $? != 0 ]] ; then
      echo "INSTALLING git"
      sudo apt-get install git
    else
      echo "git was installed"
      git --version
    fi
  fi
fi

cd ~/
DIR=~/node-manager
if [ ! -d "$DIR" ] || [ ! "$(ls -A $DIR)" ]; then
  rm -rf $DIR
  echo "Cloning node-manager"
  git clone https://github.com/grssvinay/node-manager.git
  cd node-manager
  npm install
  node index.js
else
  echo "Error: ${DIR} with files found. Can not continue with installation."
  exit 1
fi
