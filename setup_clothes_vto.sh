#!/bin/bash

# Script to set up and run the IDM-VTON project

# Step 1: Clone the public repository
echo "Cloning the public repository..."
git clone https://github.com/nishi-v/clothes_virtual_tryon.git
cd clothes_virtual_tryon || { echo "Failed to enter clothes_virtual_tryon directory."; exit 1; }

# Step 2: Install Python dependencies from requirements.txt in the clothes_virtual_tryon folder
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Step 3: Enter IDM-VTON directory and download required models
echo "Entering IDM-VTON directory and downloading required models..."
cd IDM-VTON || { echo "Failed to enter IDM-VTON directory."; exit 1; }

# Download DensePose model
wget -P ./ckpt/densepose/ https://huggingface.co/yisol/IDM-VTON/resolve/main/densepose/model_final_162be9.pkl

# Download Human Parsing models
wget -P ./ckpt/humanparsing/ https://huggingface.co/levihsu/OOTDiffusion/resolve/main/checkpoints/humanparsing/parsing_atr.onnx
wget -P ./ckpt/humanparsing/ https://huggingface.co/levihsu/OOTDiffusion/resolve/main/checkpoints/humanparsing/parsing_lip.onnx

# Download OpenPose model
wget -P ./ckpt/openpose/ckpts/ https://huggingface.co/lllyasviel/ControlNet/resolve/main/annotator/ckpts/body_pose_model.pth

echo "Model downloads completed."

# Step 4: Install Git LFS in home directory
echo "Installing Git LFS..."
wget https://github.com/git-lfs/git-lfs/releases/latest/download/git-lfs-linux-amd64.tar.gz
tar -xvzf git-lfs-linux-amd64.tar.gz
cd git-lfs-*

# Move Git LFS to a directory in your home (e.g., ~/.local/bin)
mkdir -p ~/.local/bin
mv git-lfs ~/.local/bin/
chmod +x ~/.local/bin/git-lfs

# Clean up
cd ..
rm -rf git-lfs-* git-lfs-linux-amd64.tar.gz

# Step 5: Set up yisol folder and clone the repository
mkdir yisol
cd yisol

echo "Cloning the Hugging Face repository..."
~/.local/bin/git-lfs install
git clone https://huggingface.co/yisol/IDM-VTON

# Step 6: Pull LFS content
cd IDM-VTON
~/.local/bin/git-lfs pull

# Step 7: Run the Gradio demo
cd ..
echo "Running the Gradio demo..."
python3 gradio_demo/app.py
