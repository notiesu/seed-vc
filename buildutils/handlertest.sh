#!/bin/sh

cd ..

python handler.py \
    --test_input '{
        "input": {
            "source_path": "../inputs/example_source.wav",
            "target_path": "../inputs/example_target.wav",
            "output_path": "output",
            "inference_flag": true
        }
    }'
