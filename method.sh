print_spacer () {
   print_style "\n" 
   print_style "### \n" 
} 
print_style () {

    if [ "$2" == "info" ] ; then #light blue
        COLOR="96m";
    elif [ "$2" == "success" ] ; then #green
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then #yellow
        COLOR="93m";
    elif [ "$2" == "danger" ] ; then #red
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR \n" "$1";
}
get_root_password () {
    print_style "Récupération d'un shell root" "warning"    
    if 
        [[ -z "${CI}" ]]; 
        then
            sudo -v # Ask for the administrator password upfront
        while true; 
            do 
                sudo -n true; 
                sleep 60; 
                kill -0 "$$" || exit; 
            done 2>/dev/null &
    fi
}
get_current_arch () {
    arch=$(uname -m);
    case $arch in
        x86_64)
            type="Mac Intel";
        ;;
        arm64)
            type="Mac ARM";
        ;;
    esac
    print_style "Démarrage de l'installation de sur $type" "info"
      
}
handle_apple_customisation () {
    print_style "Passer en tap-to-click" "info"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    print_style "Ne plus proposer TimeMachine lors de l'introduction d'un disque" "info"
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
    print_style "Augmentation de la vitesse du clavier" "info"
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
    print_style "Le dock sera caché automatiquement" "info"
    defaults write com.apple.dock autohide -bool true
    print_style "Modification du volume du son de démarrage" "info"
    sudo nvram SystemAudioVolume=%80
    osascript -e 'tell application "System Preferences" to quit'
    print_style "Modification du Finder" "Warning"
    print_style  "Finder:  Utiliser le répertoire courant comme champ de recherche par défaut dans le Finder" "info"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    print_style "Finder: Modification du dossier par défaut" "info"
    defaults write com.apple.finder NewWindowTarget -string "PfDe"
    print_style "Finder: Affichage des fichiers cachés" "info"
    defaults write com.apple.finder AppleShowAllFiles -bool true
    print_style "Finder: Affichage des extensions de fichier" "info"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    print_style "Finder: Affichage de la barre de statut" "info"
    defaults write com.apple.finder ShowStatusBar -bool true            # Finder: Show status bar
    print_style "Finder: Affichage du chemin" "info"
    defaults write com.apple.finder ShowPathbar -bool true
    print_style "Finder: Afficher le chemin POSIX complet comme titre de la fenêtre" "info"
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true  # Finder: Display full POSIX path as window title
    print_style "Finder: Conserver les dossiers en haut de l'écran lors du tri par nom" "info"
    defaults write com.apple.finder _FXSortFoldersFirst -bool true      # Finder: Keep folders on top when sorting by name
    print_style "Finder: Afficher le dossier /Volumes" "info"
    sudo chflags nohidden /Volumes # Show the /Volumes folder
    print_style "modification de la configuration" "success"
    print_spacer
}    
install_rosetta_2 () {
        arg=$(get_current_arch);  
    if [[ $arch  -eq  "arm64" ]];
        then
        echo "Souhaitez vous effectuer les modification de la configuration (o/n) défaut o"
        read accept;
    fi
    if [ "$accept" = "o" ]; 
        then
            print_style "Vous êtes sur une architecture ARM installation de rosetta 2 " "warning"
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license --force >> /dev/null 2>&1
            print_style "Installation effectué " "success"
    fi   
}
install_xcode_command_line_tools () {
if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}" ; then
    print_style "Mise à jour de command-line-tools en cours" "warning"
    print_style "Cette procédure peut-être assez longue" "warning"
    softwareupdate --all --install --force >> /dev/null 2>&1
else
    print_style "Installation de command-line-tools en cours" "warning"
    print_style "Cette procédure peut-être assez longue" "warning"
    xcode-select --install >> /dev/null 2>&1
fi
}


install_homebrew () {
    print_style "Installation de homebrew en cours" "warning"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    brew update
    print_style "Installation effectué " "success"

}
list_homebrew_packages () {
    print_style "Liste des paquets qui seront installés"
    while IFS=: read -r package description; 
    do
        print_style "$package  : $description" "info"
    done < .packages

}
install_homebrew_package_all() {
    while IFS=: read -r package description; 
    do
        print_style "Installation du package $package en cours" "warning"
        brew install $package;
    done < .packages
}
install_nvm () {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash >> /dev/null 2>&1
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
}
ask(){
    print_style "$1" "warning"
    read -p "$2 : " accept
}
install_oh_my_zsh_font_packages () {
    brew tap homebrew/cask-fonts &&
    brew install --cask font-roboto-mono-nerd-font
}
install_oh_my_zsh () {
    print_style "Installation de oh-my-zsh en cours" "warning"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
install_oh_my_zsh_themes () {
    print_style "Installation des thèmes de oh-my-zsh en cours" "warning"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
    echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}
function installdmg {
    set -x
    tempd=$(mktemp -d)
    curl $1 > $tempd/pkg.dmg
    listing=$(sudo hdiutil attach $tempd/pkg.dmg | grep Volumes)
    volume=$(echo "$listing" | cut -f 3)
    if [ -e "$volume"/*.app ]; then
      sudo cp -rf "$volume"/*.app /Applications
    elif [ -e "$volume"/*.pkg ]; then
      package=$(ls -1 "$volume" | grep .pkg | head -1)
      sudo installer -pkg "$volume"/"$package" -target /
    fi
    sudo hdiutil detach "$volume";
    rm -rf $tempd
    set +x
}