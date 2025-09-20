#!/bin/sh

cd ..

#get env variables
export $(cat .env | xargs)
# #test inference
python handler.py \
    --test_input '{
        "input": {
            "source_path": "../inputs/example_source.wav",
            "target_path": "../inputs/example_target.wav",
            "output_path": "output",
            "inference_flag": true
        }
    }'

#test training
python handler.py \
    --test_input '{
        "input": {
            "inference_flag": false,
            "training_data": ${TRAINING_DATA_DIR}
        }
    }'
