#!/bin/bash

# Export specific ENV variables to /etc/rp_environment
echo "Exporting environment variables..."
printenv | grep -E '^RUNPOD_|^PATH=|^_=' | sed 's/^\(.*\)=\(.*\)$/export \1="\2"/' >> /etc/rp_environment
echo 'source /etc/rp_environment' >> ~/.bashrc

if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo $PUBLIC_KEY >> ~/.ssh/authorized_keys
    chmod 700 -R ~/.ssh
    # Start the SSH service in the background
    service ssh start
else
    echo "No PUBLIC_KEY ENV variable provided, not starting openSSH daemon"
fi

# Check if JUPYTER_PASSWORD is set and not empty
if [ -n "$JUPYTER_PASSWORD" ]; then
    # Set JUPYTER_TOKEN to the value of JUPYTER_PASSWORD
    export JUPYTER_TOKEN="$JUPYTER_PASSWORD"
fi

if [ "$JUPYTER_DISABLE" != "1" ]; then
    # Run Jupyter Lab in the background
    jupyter lab --allow-root --ip 0.0.0.0 &
fi

# Execute the passed arguments (CMD)
exec "$@"
