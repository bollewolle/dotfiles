#!/usr/bin/env bash
set -eu

log_color() {
  color_code="$1"
  shift

  printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() {
  log_color "0;31" "$@"
}

log_blue() {
  log_color "0;34" "$@"
}

log_task() {
  log_blue "🔃" "$@"
}

log_manual_action() {
  log_red "⚠️" "$@"
}

log_error() {
  log_red "❌" "$@"
}

error() {
  log_error "$@"
  exit 1
}

sudo() {
  # shellcheck disable=SC2312
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    if ! command sudo --non-interactive true 2>/dev/null; then
      log_manual_action "Root privileges are required, please enter your password below"
      command sudo --validate
    fi
    command sudo "$@"
  fi
}

git_clean() {
  path=$(realpath "$1")
  remote="$2"
  branch="$3"

  log_task "Cleaning '${path}' with '${remote}' at branch '${branch}'"
  git="git -C ${path}"
  # Ensure that the remote is set to the correct URL
  if ${git} remote | grep -q "^origin$"; then
    ${git} remote set-url origin "${remote}"
  else
    ${git} remote add origin "${remote}"
  fi
  ${git} checkout -B "${branch}"
  ${git} fetch origin "${branch}"
  ${git} reset --hard FETCH_HEAD
  ${git} clean -fdx
  unset path remote branch git
}

read_env() {
  env_file="${HOME}/.env"
  if [ -f "$env_file" ]; then
    log_task "Reading environment variables from '$env_file'"
    set -a
    # shellcheck source=${HOME}/.env
    . "$env_file"
    set +a
  else
    echo "Choose the type of installation you want for this machine"
    select INSTALLATION_TYPE in minimal regular server workstation
    do
        if [[ -n "$INSTALLATION_TYPE" ]]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    printf "INSTALLATION_TYPE=%s\n" "$INSTALLATION_TYPE" >> "$env_file"

    echo "Do you want secrets to be applied to this machine"
    select APPLY_SECRETS in true false
    do
        if [[ -n "$APPLY_SECRETS" ]]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    printf "APPLY_SECRETS=%s\n" "$APPLY_SECRETS" >> "$env_file"

    log_task "Created .env file with INSTALLATION_TYPE=$INSTALLATION_TYPE and APPLY_SECRETS=$APPLY_SECRETS"
    
    chmod 600 "$env_file"
    
    set -a
    # shellcheck source=${HOME}/.env
    . "$env_file"
    set +a
  fi
}

darwin_check_full_disk_access() {
  if [ "$(uname -s)" = "Darwin" ]; then
    if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
      log_error "This script requires your terminal app to have Full Disk Access. Add this terminal to the Full Disk Access list in System Preferences > Security & Privacy, quit the app, and re-run this script."
      open 'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles'
      exit 1
    else
      log_task "Your terminal has Full Disk Access"
    fi
  fi
}

darwin_check_full_disk_access
read_env

DOTFILES_REPO_HOST=${DOTFILES_REPO_HOST:-"https://github.com"}
DOTFILES_USER=${DOTFILES_USER:-"bollewolle"}
DOTFILES_REPO="${DOTFILES_REPO_HOST}/${DOTFILES_USER}/dotfiles"
DOTFILES_BRANCH=${DOTFILES_BRANCH:-"main"}
DOTFILES_DIR="${HOME}/.dotfiles"

if ! command -v git >/dev/null 2>&1; then
  if grep -q "ID=debian" /etc/os-release || grep -q "ID=ubuntu" /etc/os-release; then
    log_task "Debian based system detected, installing git..."
    sudo apt update --yes
    sudo apt install --yes --no-install-recommends git
  else
    error "Git cannot be installed, aborting..."
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  log_task "MacOS detected."
  if [ ! "$(xcode-select --print-path)" ]; then
    log_task "Command Line Tools for Xcode not found. Installing from softwareupdate…"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
    softwareupdate -i "$PROD" --verbose;
  else
    log_task "Command Line Tools for Xcode have been installed."
  fi
fi

if [ -d "${DOTFILES_DIR}" ]; then
  git_clean "${DOTFILES_DIR}" "${DOTFILES_REPO}" "${DOTFILES_BRANCH}"
else
  log_task "Cloning '${DOTFILES_REPO}' at branch '${DOTFILES_BRANCH}' to '${DOTFILES_DIR}'"
  git clone --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

if [ -f "${DOTFILES_DIR}/install.sh" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
elif [ -f "${DOTFILES_DIR}/install" ]; then
  INSTALL_SCRIPT="${DOTFILES_DIR}/install"
else
  error "No install script found in the dotfiles."
fi

log_task "Running '${INSTALL_SCRIPT}'"
exec "${INSTALL_SCRIPT}" "$@"