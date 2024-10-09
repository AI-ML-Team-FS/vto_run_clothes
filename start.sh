#!/bin/bash
set -e

# Export environment variables
printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
echo 'source /etc/rp_environment' >> ~/.bashrc

# Setup SSH for no authentication
echo "Setting up SSH with no authentication..."

# Generate a new SSH key pair if one doesn't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
fi

# Configure SSH to allow root login without password
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config

# Start SSH service
service ssh start

# Start nginx service
service nginx start

# Start the Gradio app
echo "Starting Virtual Try-On Gradio app..."
cd /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon/IDM-VTON
python3 gradio_demo/app.py --server_name 0.0.0.0 --server_port 7860 &

# Wait for the Gradio app to start
echo "Waiting for Gradio app to start..."
while ! nc -z localhost 7860; do   
  sleep 1
done
echo "Gradio app is ready."

echo "Services started. Container is ready."

# Keep the container running
tail -f /dev/null