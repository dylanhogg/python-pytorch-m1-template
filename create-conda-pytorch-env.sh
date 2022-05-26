#!/bin/bash
set -e

# Create a conda environment with GPU-accelerated PyTorch on Mac M1
# Assumes you have conda or conda miniforge installed
# If on OSX you can `brew install miniforge` otherwise see instructions at: https://github.com/conda-forge/miniforge

# Refs:
# https://github.com/conda-forge/miniforge/
# https://pytorch.org/blog/introducing-accelerated-pytorch-training-on-mac/
# https://sebastianraschka.com/blog/2022/pytorch-m1-gpu.html
# https://www.mrdbourke.com/pytorch-apple-silicon/
# https://github.com/mrdbourke/pytorch-apple-silicon/

echo "***** CHECK: valid Apple Silicon (arm64) architecture"
if [[ $(uname -m) != "arm64" ]] ; then
  echo "ERROR: GPU-accelerated PyTorch on Mac M1 is only available on Apple Silicon (arm64). Your machine is $(uname -m)"
  exit 1
else
  echo "Architecture $(uname -m) OK"
fi

echo "***** CHECK: valid macOS version"
if [[ $(uname) != Darwin ]] || [[ $(sw_vers -productName) != macOS ]] || [[ $(sw_vers -productVersion | cut -c1-2) -lt 11 ]] ; then
  echo "ERROR: GPU-accelerated PyTorch on Mac M1 is only available on macOS 11 and later. You are running $(sw_vers -productVersion)"
  exit 1
else
  echo "macOS $(sw_vers -productVersion) version OK"
fi

echo "***** CREATE: conda evironment"
conda create -y --prefix ./env python=3.8
eval "$(conda shell.bash hook)"
conda activate ./env

echo "***** INSTALLING: PyTorch nightly (GPU only on nightly as of May 2022)..."
pip3 install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cpu
conda list --export > conda_export_pytorch_only.txt

echo "***** INSTALLING: requirements..."
conda install -y --file requirements.txt
conda list --export > conda_export_requirements_included.txt

echo "***** FINISHED: showing env info..."
python --version
conda list | grep torch

echo "activate env with: 'conda activate ./env'"
echo "run jupyter with: jupyter lab'"
