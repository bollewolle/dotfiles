#!/bin/bash
# run_after_ scripts are always run in alphabetical order after updating the dotfiles
# Purpose: Use this script to update everything on your system after the dotfiles have been updated.
echo "💡 Upgrade all the things..."

echo "You are using $CHEZMOI_SOURCE_DIR as Chezmoi source directory."

if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/installation-type.sh
else
    echo "☢️  No installation type set, did you run this script directly? Assuming 'workstation' installation."
    INSTALLATION_TYPE=workstation
fi

# Install source tooling (e.g. PATH)
if [[ -n "${CHEZMOI_SOURCE_DIR}" ]]; then
    . ${CHEZMOI_SOURCE_DIR}/../scripts/source-tooling.sh
fi

# chezmoi
chezmoi upgrade

# portainer
if command -v docker >/dev/null 2>&1; then
    echo "💡 Updating portainer agent..."
    # Docker commands
    docker stop portainer_agent
    docker rm portainer_agent
    docker pull portainer/agent:latest
    docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent:latest
else
    echo "⚠️ Docker is not installed or not found in the path. Please install Docker."
fi

# topgrade (upgrade everything)
topgrade || true