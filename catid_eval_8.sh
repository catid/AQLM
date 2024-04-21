export CUDA_VISIBLE_DEVICES=0,1,2,3
export MODEL_PATH=Meta-Llama-3-8B-Instruct
export DATASET=pajama
export FINETUNE_PATH=cat-llama-3-8b-instruct-aqlm-finetune
export WANDB_PROJECT=aqlm
export WANDB_NAME=aqlm8

python lmeval.py \
    --model hf-causal \
    --model_args pretrained=$MODEL_PATH,dtype=float16,use_accelerate=True \
    --load $FINETUNE_PATH \
    --tasks winogrande,piqa,hellaswag,arc_easy,arc_challenge \
    --batch_size 1
