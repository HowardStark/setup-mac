#!/bin/bash

command -v brew >/dev/null && echo "Brew found." || {
    echo "Brew not found. Installing Brew";
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

APPLICATIONS_PATH="/Applications/"

SOLARIZED="./solarized"
SOLARIZED_VIM="$SOLARIZED/vim-colors-solarized"
SOLARIZED_VIM_COLOR="$SOLARIZED_VIM/colors/solarized.vim"

VIM_PATH="$HOME/.vim"
VIM_COLORS="$VIM_PATH/colors"

echo "Checking VIM configuration..."
if [[ ! -d "$VIM_PATH" ]]
then
    echo "$VIM_PATH not found. Creating $VIM_PATH..."
    mkdir $VIM_PATH
    mkdir $VIM_COLORS
    echo "Solarized not found. Installing Solarized..."
    curl -o -s http://ethanschoonover.com/solarized/files/solarized.zip
    unzip solarized.zip
    mv $SOLARIZED_VIM_COLOR $VIM_COLORS
elif [[ ! -d "$VIM_COLORS" ]]
then
    echo "$VIM_COLORS not found. Creating $VIM_COLORS"
    echo "Solarized not found. Installing Solarized..."
    curl -o -s http://ethanschoonover.com/solarized/files/solarized.zip
    unzip solarized.zip
    mkdir $VIM_COLORS
    mv $SOLARIZED_VIM_COLOR $VIM_COLORS
elif [[ ! -e "$VIM_COLORS/solarized.vim" ]]
then
    echo "Solarized not found. Installing Solarized..."
    curl -o -s http://ethanschoonover.com/solarized/files/solarized.zip
    unzip solarized.zip
    mv $SOLARIZED_VIM_COLOR $VIM_COLORS
else
    echo "Solarized found."
fi

ATOM_PATH="/Applications/Atom.app"

if [[ ! -d "$ATOM_PATH" ]]
then
    echo "$ATOM_PATH not found. Installing $ATOM_PATH"
    GITHUB_RELEASES=$(curl -s -L https://github.com/atom/atom/releases/latest)
    ATOM_URL="https://github.com"
    ATOM_URL=$ATOM_URL$(echo "$GITHUB_RELEASES" | grep "<a href=\"/atom/atom/releases/download/.*/atom-mac.zip" | awk -F '"' '{print $2}')
    curl -L -O $ATOM_URL > "./atom-mac.zip"
    unzip "atom-mac.zip"
    rm -f "atom-mac.zip"
    sudo mv "Atom.app" "/Applications/"
else
    echo "$ATOM_PATH found."
fi

GIST_PACKAGES=$(curl -s https://gist.githubusercontent.com/HowardStark/16ff8e2beef34adca7f1/raw/)
ATOM_APM="$ATOM_PATH/Contents/Resources/app/apm/bin/apm"
ATOM_PACKAGES=$($ATOM_APM list)

INSTALLED_PACKAGE=false
INSTALLED_PACKAGES=0

echo "Checking Atom Packages..."
while read p
do
    echo "$ATOM_PACKAGES" | grep -q $p
    if [[ $? == 1 ]]
    then
        echo "Installing $p..."
        $ATOM_APM install $p
        INSTALLED_PACKAGE=true
    fi
done <<< "$GIST_PACKAGES"

if [[ $INSTALLED_PACKAGE == true ]]
then
    echo "Is Atom active?"
    ps -ef | grep -q "$ATOM_PATH"
    if [[ $? == 0 ]]
    then
        echo "Yes. Closing."
        osascript -e 'tell application "Atom" to quit saving no'
        open -a "Atom"
    else
        echo "No. Doing nothing."
    fi
else
    echo "No new packages."
fi
