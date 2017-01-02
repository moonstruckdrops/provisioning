#!/bin/bash -e

declare -r XCODE_URL="https://itunes.apple.com/jp/app/id497799835"

function install_xcode() {
    # xcodeのバージョンチェック
    xcodebuild -version > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        notify_osx "Xcode is installed."
    else
        notify_osx "Xcode is not intalled."
        notify_osx "See Xcode at $XCODE_URL"
        # xcodeのcommand line toolsのインストール
        xcode-select --install
        softwareupdate -i CommandLineTools
        xcodebuild -license
    fi
}

function install_homebrew() {
    notify_osx "install homebrew"
    which brew > /dev/null 2>&1
    if [ "$?" -ne 0 ]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew update
}

function notify_osx() {
    osascript -e "display notification \"${1}\" with title \"osx-provisioing\""
    say ${1}
}
