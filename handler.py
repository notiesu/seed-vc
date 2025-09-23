import runpod
import os
import subprocess

def handler(job):
    # Get the input from the job
    input = job.get("input", {})
    inference_flag = input.get("inference_flag", False)
    args = []
    for key, value in input.items():
        if value is not None and key != "inference_flag":
            args.append(f"--{key}")
            args.append(str(value))

    runinference = ["./api-inference.sh"] + args
    runtrain = ["./api-train.sh"] + args

    # Call the voice cloning script

    if inference_flag:
        subprocess.run(runinference, check=True)
    else:
        subprocess.run(runtrain, check=True)


# Start the serverless handler
runpod.serverless.start({"handler": handler})
