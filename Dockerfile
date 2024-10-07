FROM python:3.10-slim

# Set the working directory
WORKDIR /teamspace/studios/this_studio/vto_run_clothes

# Copy runpod.yaml and nginx.conf
COPY runpod.yaml /teamspace/studios/this_studio/vto_run_clothes/runpod.yaml
COPY nginx.conf /teamspace/studios/this_studio/vto_run_clothes/nginx.conf

# Install required packages, including nginx and openssh-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git git-lfs nginx openssh-server libgl1-mesa-glx libglib2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global http.postBuffer 1048576000

# Clone the repository
RUN git clone --branch main --depth 1 https://github.com/AI-ML-Team-FS/clothes_virtual_tryon.git

# Set the working directory to the cloned repository
WORKDIR /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon

# Install Python dependencies from the cloned repository's requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Download models for DensePose, Human Parsing, and OpenPose
RUN mkdir -p IDM-VTON/ckpt/densepose IDM-VTON/ckpt/humanparsing IDM-VTON/ckpt/openpose/ckpts && \
    wget -P IDM-VTON/ckpt/densepose/ https://huggingface.co/yisol/IDM-VTON/resolve/main/densepose/model_final_162be9.pkl && \
    wget -P IDM-VTON/ckpt/humanparsing/ https://huggingface.co/levihsu/OOTDiffusion/resolve/main/checkpoints/humanparsing/parsing_atr.onnx && \
    wget -P IDM-VTON/ckpt/humanparsing/ https://huggingface.co/levihsu/OOTDiffusion/resolve/main/checkpoints/humanparsing/parsing_lip.onnx && \
    wget -P IDM-VTON/ckpt/openpose/ckpts/ https://huggingface.co/lllyasviel/ControlNet/resolve/main/annotator/ckpts/body_pose_model.pth

# Set up git-lfs and clone Hugging Face repository
RUN git lfs install && \
    mkdir -p IDM-VTON/yisol && \
    cd IDM-VTON/yisol && \
    git clone https://huggingface.co/yisol/IDM-VTON

# Change working directory to the IDM-VTON folder to run the Gradio demo
WORKDIR /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon/IDM-VTON

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx and the Gradio demo
CMD service nginx start && python3 gradio_demo/app.py