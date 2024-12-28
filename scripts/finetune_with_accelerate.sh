export CUDA_VISIBLE_DEVICES=1

MODEL_SIZE=7B
NUM_GPUS=1
BATCH_SIZE_PER_GPU=1
TOTAL_BATCH_SIZE=128
GRADIENT_ACC_STEPS=$(($TOTAL_BATCH_SIZE/$NUM_GPUS/$BATCH_SIZE_PER_GPU))
echo "Training llama model ${MODEL_SIZE} using $NUM_GPUS GPUs, $BATCH_SIZE_PER_GPU batch size per GPU, $GRADIENT_ACC_STEPS gradient accumulation steps"

# You can also set --gradient_checkpointing or use `stage3_offloading_accelerate.conf` to save memory, 
# but it will trade off speed.
accelerate launch \
    --mixed_precision bf16 \
    --num_machines 1 \
    --num_processes $NUM_GPUS \
    --use_deepspeed \
    --deepspeed_config_file configs/ds_configs/stage3_no_offloading_accelerate.conf \
    open_instruct/finetune.py \
    --model_name_or_path /data1/rzw/models/Meta-Llama-3-8B-Instruct \
    --use_flash_attn \
    --tokenizer_name /data1/rzw/models/Meta-Llama-3-8B-Instruct \
    --use_slow_tokenizer \
    --train_file /data1/rzw/CODE/open-instruct_old/data/processed/tulu_v2/tulu_v2_filtered_data.jsonl \
    --max_seq_length 8192 \
    --preprocessing_num_workers 128 \
    --per_device_train_batch_size $BATCH_SIZE_PER_GPU \
    --gradient_accumulation_steps $GRADIENT_ACC_STEPS \
    --learning_rate 2e-5 \
    --lr_scheduler_type linear \
    --warmup_ratio 0.03 \
    --weight_decay 0. \
    --num_train_epochs 2 \
    --output_dir output/tulu_v2_${MODEL_SIZE}/ \
    --with_tracking \
    --report_to tensorboard \
    --logging_steps 1