#!/bin/bash

# start Mac Os X installer
# include method 
. method.sh
installdmg https://waitlist.withfig.com/download/fc898277-66c1-44a5-be37-aae838912f80\?now\=true
exit;
# check Architecture
get_root_password
get_current_arch
handle_apple_customisation
install_xcode_command_line_tools
install_rosetta_2
install_nvm
install_homebrew
if  hash brew
    then
        list_homebrew_packages
        ask "lancez l'installation default oui" "(o/n)";
        if [[ $accept = "o" || -z ${accept} ]]
            then
                #install_homebrew_package_all
                echo ""
        fi
fi
install_oh_my_zsh_font_packages
install_oh_my_zsh
install_oh_my_zsh_themes