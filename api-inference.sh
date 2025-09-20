#!/bin/sh

#if micromamba exists, append micromamba run -n appenv to the command
if [ -f /opt/micromamba/bin/micromamba ]; then
    MICROMAMBA="micromamba run -n appenv"
else
    MICROMAMBA=""
fi

python $MICROMAMBA inference_v2.py "$@"