#!/bin/sh
# activate environment and run inference
micromamba run -n appenv python inference_v2.py "$@"

# run handler
python -u /handler.py