# batch_size and finetune_batch_size must be divisible by number of GPUs

export CUDA_VISIBLE_DEVICES=0,1,2,3
export MODEL_PATH=Meta-Llama-3-8B-Instruct
export DATASET_PATH=pajama
export SAVE_PATH=cat-llama-3-8b-instruct-aqlm-save
export FINETUNE_PATH=cat-llama-3-8b-instruct-aqlm-finetune
export WANDB_PROJECT=aqlm
export WANDB_NAME=aqlm8

 python finetune.py \
  --base_model $MODEL_PATH \
  --quant_model $SAVE_PATH \
  --dataset $DATASET_PATH \
  --model_seqlen=8192 \
  --eval_datasets wikitext2 \
  --nsamples=1024 \
  --val_size=128 \
  --lr=1e-5 \
  --adam_beta1=0.90 \
  --adam_beta2=0.999 \
  --epochs=1 \
  --early_stop=3 \
  --batch_size=8 \
  --microbatch_size=4 \
  --save $FINETUNE_PATH \
  --gradient_checkpointing \
  --offload_activations \
  --device_map auto \
  --amp \
  --wandb 
