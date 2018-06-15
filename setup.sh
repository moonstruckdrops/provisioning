#!/bin/bash -e

. $(dirname $0)/osx.sh

function install_ansible() {
    echo "install_ansible"

    if [ `echo "${OSTYPE}" |grep "linux*"` ]; then
        which pip >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "not found command pip"
            echo "install pip"
            sudo easy_install pip
        fi

        sudo pip install --upgrade pip
        sudo pip install --upgrade setuptools
        sudo dnf install -y gcc
        sudo dnf install -y openssl-devel
        sudo dnf install -y python-devel
        sudo dnf install -y rpm-build
        sudo dnf install -y python-dnf

        which ansible >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "not found command ansible"
            echo "install ansible"
            sudo pip install ansible
        fi
    else
        brew install python
        brew install ansible
    fi
}

function provisioning() {
    if [ `echo "${OSTYPE}" |grep "linux*"` ]; then
        ansible-playbook linux.yml --connection=local --vault-password-file .vault_pass --extra-vars=@vault.yml --ask-become-pass
    else
        ansible-playbook osx.yml --connection=local --vault-password-file .vault_pass --extra-vars=@vault.yml --ask-become-pass
        # brew linkapps
        brew cleanup
    fi
}

function setup_osx() {
    notify_osx "start osx setup"
    install_xcode
    install_homebrew
    notify_osx "input password"
    install_ansible
    provisioning

    mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql56)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
    echo "mysqladmin -u root password \"your password\""
    echo "mysqladmin -u root -h your hostname password \"your password\""
    notify_osx "finish osx setup"
}

function setup_linux() {
    install_ansible
    provisioning
    LANG=C xdg-user-dirs-gtk-update
}

function _main() {
    if [ `echo "${OSTYPE}" |grep "linux*"` ]; then
        setup_linux
    else
        setup_osx
    fi
}

_main
