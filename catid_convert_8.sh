# batch_size and finetune_batch_size must be divisible by number of GPUs

export CUDA_VISIBLE_DEVICES=0,1,2,3
export MODEL_PATH=Meta-Llama-3-8B-Instruct
export DATASET_PATH=pajama
export SAVE_PATH=cat-llama-3-8b-instruct-aqlm
export OUT_PATH=cat-llama-3-8b-instruct-aqlm-hf

mkdir -p $OUT_PATH

python convert_to_hf.py --model $MODEL_PATH --in_path $SAVE_PATH --out_path $OUT_PATH
 