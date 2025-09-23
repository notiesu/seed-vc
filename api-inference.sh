#!/bin/sh

#if micromamba exists, append micromamba run -n appenv to the command
if [ -f /opt/micromamba/bin/micromamba ]; then
    MICROMAMBA="micromamba run -n appenv"
else
    MICROMAMBA=""
fi

$MICROMAMBA python inference.py "$@"