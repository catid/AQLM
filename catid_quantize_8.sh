# finetune_batch_size must be divisible by number of GPUs

export CUDA_VISIBLE_DEVICES=0,1,2,3,4   # or e.g. 0,1,2,3
export MODEL_PATH=Meta-Llama-3-8B-Instruct
export DATASET_PATH=pajama
export SAVE_PATH=cat-llama-3-8b-instruct-aqlm
export WANDB_PROJECT=aqlm
export WANDB_NAME=aqlm8

mkdir -p $SAVE_PATH

python main.py $MODEL_PATH $DATASET_PATH \
 --nsamples=1024 \
 --val_size=128 \
 --model_seqlen=8192 \
 --num_codebooks=1 \
 --nbits_per_codebook=16 \
 --in_group_size=8 \
 --out_group_size=1 \
 --relative_mse_tolerance=0.01 \
 --finetune_lr=1e-4 \
 --finetune_adam_beta1=0.90 \
 --finetune_adam_beta2=0.999 \
 --finetune_batch_size=40 \
 --finetune_max_epochs=10 \
 --finetune_early_stop=3 \
 --finetune_keep_best \
 --local_batch_size=1 \
 --offload_activations \
 --wandb \
 --save $SAVE_PATH
 
 #--resume
 
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
  --microbatch_size=1 \
  --temperature=1.0 \
  --save $DATA_PATH \
  --gradient_checkpointing \
  --amp \
  --wandb 
