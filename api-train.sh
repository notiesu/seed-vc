#!/bin/sh

if [ -f /opt/micromamba/bin/micromamba ]; then
    MICROMAMBA="micromamba run -n appenv"
else
    MICROMAMBA=""
fi

while [ "$#" -gt 0 ]; do
    case $1 in
        --run-name)
            RUN_NAME="$2"
            shift 2
            ;;
        --data-dir)
            DATASET_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

$MICROMAMBA accelerate launch train_v2.py \
--dataset-dir $DATASET_DIR \
--run-name $RUN_NAME \
--batch-size 5 \
--max-steps 1000 \
--max-epochs 1000 \
--save-every 500 \
--num-workers 0 \
--train-cfm

#output to the volume dir
cp -r runs/$RUN_NAME /runpod-volume/checkpts/$RUN_NAME