# Install

DISCLAIMER: These are my dotfiles for bootstrapping a new system. They are tailored to my needs, and may not work for you. Use at your own risk.

## macOS/linux

For a fresh install of macOS: make sure you use the same username as defined in your Chezmoi data file. Also make sure to already log into the App Store in order to make the app installation via mas-cli work correctly.

If you're on a workstation use the below command to initiate the bootstrap script. It will pull the repo and initiate Chezmoi. That in turn will run the necessary script (via a hook) to also install 1Password and the CLI for 1Password. After that Chezmoi will do what it's meant to do with all the defined files, folders, templates, scripts, ...

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

In case of Compedit issues:

    compaudit | xargs chmod g-w,o-w

## 1Password CLI

Documentation on 1Password CLI can be found here: https://developer.1password.com/docs/cli

Some usefull commands:

    # list all document stores
    op document list

    # create new document
    op document create [{ <file> | - }] [flags]

    # update existing document
    op document edit { <itemName> | <itemID> } [{ <file> | - }] [flags]

    # get content of existing document
    op document get { <itemName> | <itemID> } [flags]

# Inspiration

Biggest inspiration is the [dotfiles of benc](https://github.com/benc/dotfiles), of which I really liked the approach taken. It allows to keep a great overview, while not making it too complex and yet allowing for a lot of flexibility (e.g. still possible to make differences per device if wanted).

Also the [dotfiles of twpayne](https://github.com/twpayne/dotfiles), the creator of Chezmoi, are regularly checked. If it's by the creator then it can't be a bad approach, right?

For the Chezmoi config itself there were a lot of other inspirations, just use the search on Github and you'll find so many great configs to learn from.

The main inspiration for what I added in the "configure-darwin" script is this one: https://gist.github.com/ChristopherA/98628f8cd00c94f11ee6035d53b0d3c6. And another one is https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos.

A huge thanks to all these people, especially for making their configs available, thanks so much!
