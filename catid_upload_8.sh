export MODEL_PATH=Meta-Llama-3-8B-Instruct
export SAVE_PATH=cat-llama-3-8b-instruct-aqlm-finetune
export OUT_PATH=cat-llama-3-8b-instruct-aqlm
export HF_USERNAME=catid

mkdir -p $OUT_PATH

python convert_to_hf.py --save_safetensors $MODEL_PATH $SAVE_PATH $OUT_PATH 

huggingface-cli upload --repo-type model $HF_USERNAME/$OUT_PATH $OUT_PATH
