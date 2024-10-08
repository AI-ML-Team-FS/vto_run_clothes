# Start with a base Ubuntu 22.04 image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    PYTHONUNBUFFERED=1

WORKDIR /teamspace/studios/this_studio/vto_run_clothes

# Set up system and install dependencies, including Python 3.10
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
        git wget curl bash libgl1 software-properties-common \
        openssh-server nginx libgl1-mesa-glx libglib2.0-0 \
        git-lfs build-essential gnupg && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install --yes python3.10 python3.10-dev python3.10-venv python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen


# Set Python 3.10 as the default
RUN if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3.10 /usr/bin/python; fi && \
    if [ ! -e /usr/bin/python3 ]; then ln -s /usr/bin/python3.10 /usr/bin/python3; fi

# Clone the repository
RUN git clone --branch main --depth 1 https://github.com/AI-ML-Team-FS/clothes_virtual_tryon.git /teamspace/studios/this_studio/vto_run_clothes/clothes_virtual_tryon

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
RUN if [ -x "$(command -v nvidia-smi)" ]; then echo "NVIDIA GPU detected"; else echo "No NVIDIA GPU detected, switching to CPU-only mode"; fi

# Expose necessary ports
EXPOSE 80 22 8888

# Set default command to start your application
CMD ["/teamspace/studios/this_studio/vto_run_clothes/start.sh"]
