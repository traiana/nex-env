#!/bin/bash -eEu

PYTHON_VERSION=3.6.5
PYTHON_REQUIREMENTS="awscli boto3~=1.7.0 cmd2~=0.8.0 git+git://github.com/arcivanov/docker-squash@docker_rebase git+ssh://git@github.com/Traiana/nex-daemon@v0.1.14"

INSTALL_PREREQS=x
INSTALL_ENV=x

for arg in "$@"; do
    case "$arg" in
      --prereqs-only)
        INSTALL_PREREQS=x
        INSTALL_ENV=""
      ;;
      --env-only)
        INSTALL_PREREQS=""
        INSTALL_ENV=x
      ;;
    esac
done

if apt-get --help > /dev/null 2>&1; then
  echo "Found APT-based Linux distro"
  CMD=apt-get
elif dnf --help > /dev/null 2>&1; then
  echo "Found DNF-based Linux distro"
  CMD=dnf
elif yum --help > /dev/null 2>&1; then
  echo "Found YUM-based Linux distro"
  CMD=yum
elif brew --help > /dev/null 2>&1; then
  echo "Found Darwin/OSX"
  CMD=brew
elif [ "$(uname -s)" == "Darwin" ]; then
  echo "Found Darwin/OSX, Installing Homebrew"
  CMD=brew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Have no idea what OS I'm running on!" >&2
  exit 1
fi

SUDO="sudo"
if [ $(id -u) == "0" ]; then
  SUDO=""
fi

if [ -n "$INSTALL_PREREQS" ]; then
  if [ "$CMD" == "yum" -o "$CMD" == "dnf" ]; then
  # cat > /libs <<EOF
  # libev libevent bzip2 xz readline jemalloc c-ares pcre
  # EOF

  # cat > /devtools <<EOF
  # git autoconf automake libtool mercurial wget unix2dos gcc gcc-c++ file findutils diffutils
  # unzip patch jemalloc-devel openssl-devel libev-devel c-ares-devel jemalloc-devel libevent-devel
  # ruby24 bison zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel xz-devel
  # readline-devel pcre-devel lua-devel systemtap-sdt-devel
  # EOF
    $SUDO $CMD install -y --skip-broken gcc gcc-c++ git make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel
    if [[ "$(git --version)" == "git version 1"* ]]; then
      $SUDO $CMD remove -y git
      set +e
      curl -Ls https://raw.githubusercontent.com/Traiana/nex-env/master/enable-ius.sh | $SUDO bash
      set -e
      $SUDO $CMD install -y git2u
    fi
  fi


  if [ "$CMD" == "apt-get" ]; then
    $SUDO $CMD update
    $SUDO $CMD install -y git make build-essential libssl-dev zlib1g-dev libbz2-dev \
                          libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
                          xz-utils tk-dev
  fi
fi

if [ -n "$INSTALL_ENV" ]; then
  if [ "$CMD" == "brew" ]; then
    brew update
    if ! brew upgrade pyenv; then
      brew install pyenv
      brew install pyenv-virtualenv
    fi
  else
    curl -Ls "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer" | bash
  fi

  set +u
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  set -u

  pyenv update
  pyenv install -s $PYTHON_VERSION

  set +u
  pyenv virtualenv-delete -f nex
  pyenv virtualenv -f $PYTHON_VERSION nex
  pyenv activate nex
  set -u

  pip install -U pip~=9.0 setuptools wheel
  pip install -U $PYTHON_REQUIREMENTS
fi
