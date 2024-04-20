# Repro instructions

Set up system:

I used https://runpod.io with 4x H100 GPUs ($20/hr).  The scripts require 1, 2, 4, or 8 GPUs to evenly divide the batch sizes it uses.  Configure disk space to be 1024GB for workspace and container.  Enter the web terminal:

```bash
apt update
apt install git-lfs vim htop tmux -y
```

```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
~/miniconda3/bin/conda init bash
source ~/.bashrc

tmux
```

Set up packages:

```bash
conda create -n aqlm python=3.10 -y && conda activate aqlm

git clone https://github.com/catid/AQLM.git
cd AQLM

pip install -U -r requirements.txt

huggingface-cli login
```

Enter HF API key here from https://huggingface.co/settings/tokens and download the 8B model fast (we are paying per minute here):

```bash
pip install huggingface_hub[hf_transfer]
export HF_HUB_ENABLE_HF_TRANSFER=1
huggingface-cli download meta-llama/Meta-Llama-3-8B-Instruct --local-dir Meta-Llama-3-8B-Instruct
```

Enter WandB API key here from https://wandb.ai/authorize

```bash
wandb login
```

Quantize 8B model:

```bash
./catid_quantize_8.sh
```

Fine-tune 8B model for one epoch

```bash
./catid_finetune_8.sh
```
