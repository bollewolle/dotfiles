# Install

DISCLAIMER: These are my dotfiles for bootstrapping a new system. They are tailored to my needs, and may not work for you. Use at your own risk.

## Macos/linux

If you're on a workstation use the below command to initiate the bootstrap script. It will pull the repo and initiate Chezmoi. That in turn will run the necessary script (via a hook) to also install 1Password and the CLI. After that Chezmoi will do it's meant to do with all the defined files, folders, templates, scripts, ...

Using curl:

    sh -c "$(curl -fsLS https://raw.githubusercontent.com/bollewolle/dotfiles/main/scripts/bootstrap_dotfiles.sh)"

Using wget:

    sh -c "$(wget -qO- https://raw.githubusercontent.com/bollewolle/dotfiles/main/scripts/bootstrap_dotfiles.sh)"

# Usage

## Application Order

Chezmoi uses a specific order in which it processes the files, folders, templates, scripts, ... More information can be found
in the [Application Order](https://www.chezmoi.io/reference/application-order/) reference of the Chezmoi documentation.

## Most used commands:

    # edit dotfiles
    chezmoi edit

    # apply them on your system
    chezmoi apply

    # update system with the latest dotfiles
    chezmoi update --init

    # force run_once scripts
    chezmoi state delete-bucket --bucket=scriptState; chezmoi apply --init
    chezmoi state delete-bucket --bucket=scriptState; chezmoi update --init

## Troubleshooting

    chezmoi -v apply
    chezmoi doctor

Compedit issues:

    compaudit | xargs chmod g-w,o-w
