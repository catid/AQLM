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
 --num_codebooks=1 \
 --nbits_per_codebook=16 \
 --in_group_size=8 \
 --relative_mse_tolerance=0.01 \
 --finetune_batch_size=40 \
 --finetune_max_epochs=10 \
 --finetune_early_stop=3 \
 --finetune_keep_best \
 --local_batch_size=1 \
 --offload_activations \
 --wandb \
 --resume \
 --save $SAVE_PATH
