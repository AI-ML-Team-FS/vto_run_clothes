#!/bin/bash
set -e

# Start nginx service
service nginx start

# Setup SSH if public key is provided
if [[ $PUBLIC_KEY ]]; then
    echo "Setting up SSH..."
    mkdir -p ~/.ssh
    echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 700 -R ~/.ssh

    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
    fi

    service ssh start
fi

# Export environment variables
printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
echo 'source /etc/rp_environment' >> ~/.bashrc

# Start Jupyter Notebook if JUPYTER_PASSWORD is set
if [[ $JUPYTER_PASSWORD ]]; then
    echo "Starting Jupyter Notebook..."
    jupyter notebook --allow-root --no-browser --port=8888 --ip=0.0.0.0 --NotebookApp.token=$JUPYTER_PASSWORD --NotebookApp.allow_origin='*' --notebook-dir=/teamspace/studios/this_studio/vto_run_clothes &
fi

# Start the Gradio app
echo "Starting Virtual Try-On Gradio app..."
cd /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon/IDM-VTON
python3 gradio_demo/app.py &

echo "Services started. Container is ready."

# Keep the container running
tail -f /dev/null