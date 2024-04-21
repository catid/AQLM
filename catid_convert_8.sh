export MODEL_PATH=Meta-Llama-3-8B-Instruct
export SAVE_PATH=cat-llama-3-8b-instruct-aqlm-save
export OUT_PATH=cat-llama-3-8b-instruct-aqlm

mkdir -p $OUT_PATH

python convert_to_hf.py --save_safetensors $MODEL_PATH $SAVE_PATH $OUT_PATH 
