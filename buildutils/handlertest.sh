#!/bin/sh

cd ..

#get env variables
export $(cat .env | xargs)
# #test inference
python handler.py \
    --test_input '{
        "input": {
            "source": "../inputs/example_source.wav",
            "target": "../inputs/example_target.wav",
            "output": "output",
            "inference_flag": true
        }
    }'

#test training
python handler.py \
    --test_input '{
        "input": {
            "inference_flag": false,
            "dataset-dir": ${TRAINING_DATA_DIR}
        }
    }'
