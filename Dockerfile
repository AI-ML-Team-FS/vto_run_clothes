# Use a base image with Python 3.10
FROM python:3.10-slim AS builder

# Set the working directory inside the container
WORKDIR workspace/vto_run_clothes

# Install system dependencies and Git LFS
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget git git-lfs && \
    rm -rf /var/lib/apt/lists/*

# Increase Git buffer size
RUN git config --global http.postBuffer 1048576000

# Clone the repository from the main branch with a shallow clone
RUN git clone --branch main --depth 1 https://github.com/nishi-v/clothes_virtual_tryon.git

# Change directory to the cloned repo
WORKDIR workspace/vto_run_clothes/clothes_virtual_tryon

# Install Python dependencies from the cloned repository's requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.tx

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

# Final stage
FROM python:3.10-slim

# Copy the built files from the previous stage
COPY --from=builder /vto_run_clothes/clothes_virtual_tryon /vto_run_clothes/clothes_virtual_tryon

# Change working directory to the IDM-VTON folder to run the Gradio demo
WORKDIR workspace/vto_run_clothes/clothes_virtual_tryon/IDM-VTON

# Expose port 7860 for Gradio
EXPOSE 7860

# Run the Gradio demo from the IDM-VTON folder
CMD ["python3", "gradio_demo/app.py"]
