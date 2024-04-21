git clone https://github.com/EleutherAI/lm-evaluation-harness
cd lm-evaluation-harness

conda create -n lmeval python=3.10 -y && conda activate lmeval
pip install -e .

accelerate launch --config_file ../accelerate_config.yaml -m lm_eval --model hf \
    --model_args pretrained=catid/cat-llama-3-8b-instruct-aqlm \
    --tasks winogrande,piqa,hellaswag,arc_easy,arc_challenge \
    --batch_size 16
