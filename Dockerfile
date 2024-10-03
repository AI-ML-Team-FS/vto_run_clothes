# Base image with Python 3.8
FROM python:3.8-slim

# Set the working directory inside the container
WORKDIR /workspace/vto_run_clothes/clothes_virtual_tryon

# Install system dependencies and Git LFS
RUN apt-get update && \
    apt-get install -y wget git git-lfs && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies from the cloned repository's requirements.txt
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Change working directory to the IDM-VTON folder to run the Gradio demo
WORKDIR /workspace/vto_run_clothes/clothes_virtual_tryon/IDM-VTON

# Expose port 7860 for Gradio
EXPOSE 7860

# Run the Gradio demo from the IDM-VTON folder
CMD ["python3", "gradio_demo/app.py"]
