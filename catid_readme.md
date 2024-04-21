# Repro instructions

You will need access to the Meta-Llama-3-8B-Instruct model.  You can get access here: https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct  After you have access, continue with the instructions below.

Set up a https://wandb.ai/ account for monitoring.

Create a new HuggingFace WRITE token for uploading later: https://huggingface.co/settings/tokens?new_token=true

Fork these scripts and modify the variables at the top of all the scripts to use your own paths.

Set up system:

I used https://runpod.io with 4 x H100 80GB SXM5 ($20/hr).  The scripts require 1, 2, 4, or 8 GPUs to evenly divide the batch sizes it uses.  Configure disk space to be 1024GB for workspace and container.  Enter the web terminal:

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

Enter HuggingFace WRITE token from https://huggingface.co/settings/tokens and download the 8B model fast (we are paying per minute here):

```bash
pip install huggingface_hub[hf_transfer]
export HF_HUB_ENABLE_HF_TRANSFER=1
huggingface-cli download meta-llama/Meta-Llama-3-8B-Instruct --local-dir Meta-Llama-3-8B-Instruct
```

Enter WandB API key from https://wandb.ai/authorize

```bash
wandb login
```

Quantize 8B model (takes about 16 hours, costing ~$400).  This uses all 4 GPUs.

```bash
./catid_quantize_8.sh
```

Global fine-tune 8B model for one epoch (takes about 1 hour).  This uses just one GPU.

```bash
./catid_finetune_8.sh
```

This calculates perplexity on wikitext2 dataset.  My result: `7.5590`

Evaluate 8B model (takes about 1 hour).  This uses all 4 GPUs.

```bash
pip install -r lm-evaluation-harness/requirements.txt
pip install sqlitedict sacrebleu scikit-learn omegaconf pycountry rouge_score
./catid_eval_8.sh
```

You should already be authenticated with HuggingFace.

```bash
pip install aqlm[gpu]

export HF_HUB_ENABLE_HF_TRANSFER=1
./catid_upload_8.sh
```

You then need to add the missing files to the repo.  You should do this on your own Linux server instead of the expensive one.

You have to add your SSH key `ssh-keygen -t ed25519` (if needed) and `cat ~/.ssh/id_ed25519.pub` on the machine from https://huggingface.co/settings/keys/add?type=ssh

```bash
export HF_USERNAME=catid
export HF_MODEL=cat-llama-3-8b-instruct-aqlm
export ORIG_MODEL=Meta-Llama-3-8B-Instruct
GIT_LFS_SKIP_SMUDGE=1 git clone git@hf.co:$HF_USERNAME/$HF_MODEL
cp $ORIG_MODEL/generation_config.json $HF_MODEL/
cp $ORIG_MODEL/tokenizer* $HF_MODEL/
cp $ORIG_MODEL/special_tokens_map.json $HF_MODEL/

cd $HF_MODEL
git add *
git commit -m "Add files from $ORIG_MODEL"
git push
cd ..
```

Make sure the `generation_config.json` file contains the 128009 `eos_token_id` which the original Meta release failed to include:

```
{
  "_from_model_config": true,
  "bos_token_id": 128000,
  "eos_token_id": [128001, 128009],
  "transformers_version": "4.40.0.dev0"
}
```

Add this text to your README.md (model card) to comply with Meta license:
```
AI Model Name: Llama 3 8B "Built with Meta Llama 3" https://llama.meta.com/llama3/license/
```

My results are uploaded here: https://huggingface.co/catid/cat-llama-3-8b-instruct-aqlm-noft (before global fine-tuning) and https://huggingface.co/catid/cat-llama-3-8b-instruct-aqlm (after global fine-tuning)

Offline evaluation:

```bash
git clone https://github.com/EleutherAI/lm-evaluation-harness
cd lm-evaluation-harness

conda create -n lmeval python=3.10 -y && conda activate lmeval
pip install -e .

pip install huggingface_cli
huggingface-cli login

# Use all GPUs for evaluation (if model fits on a single GPU):
# See other ways in the README: https://github.com/EleutherAI/lm-evaluation-harness

accelerate launch -m lm_eval --model hf \
    --model_args pretrained=meta-llama/Meta-Llama-3-8B-Instruct \
    --tasks lambada_openai,arc_easy \
    --batch_size 16
```

Baseline results:

```
hf (pretrained=meta-llama/Meta-Llama-3-8B-Instruct), gen_kwargs: (None), limit: None, num_fewshot: None, batch_size: 16
|    Tasks     |Version|Filter|n-shot|  Metric  |Value |   |Stderr|
|--------------|------:|------|-----:|----------|-----:|---|-----:|
|lambada_openai|      1|none  |     0|perplexity|3.1070|±  |0.0771|
|              |       |none  |     0|acc       |0.7174|±  |0.0063|
|arc_easy      |      1|none  |     0|acc       |0.8140|±  |0.0080|
|              |       |none  |     0|acc_norm  |0.7971|±  |0.0083|
```

AQLM quantization without global fine-tuning results:

```
pip install aqlm"[gpu,cpu]"

accelerate launch -m lm_eval --model hf \
    --model_args pretrained=catid/cat-llama-3-8b-instruct-aqlm-noft \
    --tasks lambada_openai,arc_easy \
    --batch_size 16

|    Tasks     |Version|Filter|n-shot|  Metric  |Value |   |Stderr|
|--------------|------:|------|-----:|----------|-----:|---|-----:|
|lambada_openai|      1|none  |     0|perplexity|3.0949|±  |0.0762|
|              |       |none  |     0|acc       |0.7229|±  |0.0062|
|arc_easy      |      1|none  |     0|acc       |0.8152|±  |0.0080|
|              |       |none  |     0|acc_norm  |0.7866|±  |0.0084|
```

AQLM quantization with global fine-tuning results:

```
accelerate launch -m lm_eval --model hf \
    --model_args pretrained=catid/cat-llama-3-8b-instruct-aqlm \
    --tasks lambada_openai,arc_easy \
    --batch_size 16

|    Tasks     |Version|Filter|n-shot|  Metric  |Value |   |Stderr|
|--------------|------:|------|-----:|----------|-----:|---|-----:|
|lambada_openai|      1|none  |     0|perplexity|3.0949|±  |0.0762|
|              |       |none  |     0|acc       |0.7229|±  |0.0062|
|arc_easy      |      1|none  |     0|acc       |0.8152|±  |0.0080|
|              |       |none  |     0|acc_norm  |0.7866|±  |0.0084|
```

Full final evaluation process (20 minutes on 2x 4090):

```bash
git clone https://github.com/EleutherAI/lm-evaluation-harness
cd lm-evaluation-harness

conda create -n lmeval python=3.10 -y && conda activate lmeval
pip install -e .
pip install accelerate aqlm"[gpu,cpu]"

accelerate launch lm_eval --model hf \
    --model_args pretrained=catid/cat-llama-3-8b-instruct-aqlm \
    --tasks winogrande,piqa,hellaswag,arc_easy,arc_challenge \
    --batch_size 16
```
