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

$MICROMAMBA python train.py "$@"
mkdir -p /runpod-volume/checkpts/$RUN_NAME

# Output to the volume dir
cp -r runs/$RUN_NAME /runpod-volume/checkpts/$RUN_NAME