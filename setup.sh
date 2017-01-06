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
        setup_linux
    else
        ansible-playbook osx.yml --connection=local --vault-password-file .vault_pass --extra-vars=@vault.yml --ask-become-pass
        brew linkapps
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
    notify_osx "finish osx setup"
}

function setup_linux() {
    # TODO: Linuxのセットアップで必須な内容はあればここに書く
    echo "do nothing."
    install_ansible
    provisioning
}

function _main() {
    if [ `echo "${OSTYPE}" |grep "linux*"` ]; then
        setup_linux
    else
        setup_osx
    fi
}

_main
