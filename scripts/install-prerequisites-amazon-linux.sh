#!/bin/bash -e

# Install git and Salt with basic configuration on Amazon Linux

if [ -z "$1" ]; then

  echo
  echo "Usage (run from the root of this repository):"
  echo "sudo scripts/install-prerequisites-amazon-linux.sh full git_user_name git_user_email"
  echo 
  echo "Example:"
  echo "sudo scripts/install-prerequisites-amazon-linux.sh full \"Joe Doe\" name@example.com"
  echo "Use quotes if the name contains spaces."
  echo
  echo "Run it remotely:"
  echo "\curl -sSL https://raw.githubusercontent.com/alexisbellido/salt-git-repos/master/scripts/install-prerequisites-amazon-linux.sh | sudo bash -s full \"Joe Doe\" name@example.com"
  echo

else
  TOP_DIR="/srv/salt"
  PILLAR_DIR="/srv/pillar"

  if [ "$1" == "minion" -o "$1" == "master" -o "$1" == "full" ]; then

    echo
    echo "Installing prerequisites..."
    echo

    yum update -y
    yum install git -y
    yum install vim -y

    echo
    echo "Preparing SaltStack for Amazon Linux..."
    echo

    yum install https://repo.saltstack.com/yum/amazon/salt-amzn-repo-latest-2.amzn1.noarch.rpm -y
    yum clean expire-cache

  fi
  
  if [ "$1" == "master" -o "$1" == "full" ]; then

    yum install salt-master -y

    if [[ $SUDO_COMMAND == "/bin/bash -s"* ]]; then
      ROOT_DIR="$PWD/salt-git-repos"
    else
      ROOT_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"
    fi

    if [ ! -d  "$ROOT_DIR" ]; then
      sudo -u $SUDO_USER git clone git@github.com:alexisbellido/salt-git-repos.git
    fi
    
    if [ ! -d  "$TOP_DIR" ]; then
      echo "Creating $TOP_DIR..."
      mkdir -p $TOP_DIR
      cp $ROOT_DIR/conf/srv/salt/top.sls $TOP_DIR
    fi
    
    if [ ! -d  "$PILLAR_DIR" ]; then
      echo "Creating $PILLAR_DIR..."
      mkdir -p $PILLAR_DIR
      cp -r $ROOT_DIR/conf/srv/pillar/* $PILLAR_DIR
    fi

    sed -i '/^# Added by install script$/,$d' /etc/salt/master
    cat >> /etc/salt/master << EOL

# Added by install script
file_roots:
  base:
    - /srv/salt
    - ${ROOT_DIR}

pillar_roots:
  base:
    - ${PILLAR_DIR}
  staging:
    - ${PILLAR_DIR}/staging
  production:
    - ${PILLAR_DIR}/production
EOL

    service salt-master restart

  fi
  
  if [ "$1" == "minion" -o "$1" == "full" ]; then
    yum install salt-minion -y
    service salt-minion restart 
  fi
  
  if [ "$1" == "minion" -o "$1" == "master" -o "$1" == "full" ]; then
    sudo -u $SUDO_USER git config --global user.name "$2"
    sudo -u $SUDO_USER git config --global user.email $3
  fi

fi
