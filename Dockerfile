# Start with a slim Python 3.10 image
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

WORKDIR /teamspace/studios/this_studio/vto_run_clothes

# Set up system and install dependencies
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    git wget curl bash libgl1 nginx \
    libgl1-mesa-glx libglib2.0-0 git-lfs \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev netcat-openbsd \
    openssh-server locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Clone the repository
RUN git clone --branch main --depth 1 https://github.com/AI-ML-Team-FS/clothes_virtual_tryon.git

WORKDIR /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Download models
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

WORKDIR /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon/IDM-VTON

# Copy configuration files
COPY nginx.conf /teamspace/studios/this_studio/vto_run_clothes/nginx.conf
COPY start.sh /teamspace/studios/this_studio/vto_run_clothes/start.sh
RUN chmod +x /teamspace/studios/this_studio/vto_run_clothes/start.sh

# Check for NVIDIA drivers for GPU support
RUN /bin/bash -c 'if [ -x "$(command -v nvidia-smi)" ]; then echo "NVIDIA GPU detected"; else echo "No NVIDIA GPU detected, switching to CPU-only mode"; fi'

# Expose necessary ports
EXPOSE 80 22

# Set default command to start your application
CMD ["/teamspace/studios/this_studio/vto_run_clothes/start.sh"]