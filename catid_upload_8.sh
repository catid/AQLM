export OUT_PATH=cat-llama-3-8b-instruct-aqlm

huggingface-cli upload --repo-type model catid/$OUT_PATH $OUT_PATH
