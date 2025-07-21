#!/bin/bash

# Create a folder who contains downloaded things for the setup
INSTALL_FOLDER=~/.setup
mkdir -p $INSTALL_FOLDER
MAC_SETUP_PROFILE=$INSTALL_FOLDER/setup_profile

FORMULAS=(
  git curl wget vim
  zsh zsh-completions
  lsd z
  nvm
)
CASKS=(
  raycast zen trae
  font-jetbrains-mono
  iterm2 amazon-q warp
  shottr obsidian
  spotify vlc
  slack microsoft-teams microsoft-outlook
  openvpn-connect
)

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

brew_install() {
  for formula in "${FORMULAS[@]}"; do
    brew list "$formula" &>/dev/null || brew install "$formula"
  done
  for cask in "${CASKS[@]}"; do
    brew list --cask "$cask" &>/dev/null || brew install --cask "$cask"
  done
}

setup_ohmyzsh() {
  if ! [ -d "$HOME/.oh-my-zsh" ]; then
    sudo chmod -R 755 /usr/local/share/zsh
    sudo chown -R root:staff /usr/local/share/zsh
    {
      echo "if type brew &>/dev/null; then"
      echo "  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH"
      echo "  autoload -Uz compinit"
      echo "  compinit"
      echo "fi"
    } >>$MAC_SETUP_PROFILE
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  if ! grep -q 'powerlevel10k' ~/.zshrc 2>/dev/null; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
  fi
}

git_aliases() {
  git config — global push.default current
  git config — global core.excludesfile ~/.gitignore
  git config — global color.branch auto
  git config — global color.diff auto
  git config — global color.interactive auto
  git config — global color.status auto
  git config — global alias.st status
  git config — global alias.ci commit
  git config — global alias.co checkout
  git config — global alias.br branch
  git config — global alias.lg "log — graph — pretty=format:’%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue <%an>%Creset’ — abbrev-commit — date=relative"
}

install_homebrew
brew update
brew_install
setup_ohmyzsh
git_aliases

# brew/ls
{
  echo "alias ls='lsd'"
  echo "alias l='ls -l'"
  echo "alias la='ls -a'"
  echo "alias lla='ls -la'"
  echo "alias lt='ls --tree'"
} >>$MAC_SETUP_PROFILE

# brew/z
touch ~/.z
echo '. /usr/local/etc/profile.d/z.sh' >> $MAC_SETUP_PROFILE

# brew/nvm
mkdir ~/.nvm
brew install nvm
nvm install node
brew install yarn pnpm

# brew/fonts
brew tap homebrew/cask-fonts

# reload profile files.
{
  echo "source $MAC_SETUP_PROFILE # alias and things added by mac_setup script"
}>>"$HOME/.zsh_profile"
source "$HOME/.zsh_profile"
{
  echo "source $MAC_SETUP_PROFILE # alias and things added by mac_setup script"
}>>~/.bash_profile
source ~/.bash_profile