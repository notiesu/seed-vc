import runpod
import os
import subprocess

def handler(job):
    # Get the input from the job
    input = job.get("input", {})
    source_path = input.get("source_path")
    target_path = input.get("target_path")
    output_path = input.get("output_path")
    inference_flag = input.get("inference_flag")

    # Expecting the output_dir to be passed in the job input
    print(f"source_path: {source_path}")
    print(f"target_path: {target_path}")
    print(f"output_path: {output_path}")

    #check for micromamba installation
    runwithmicromamba = ["micromamba", "run", "-n", "appenv"]
    runinference = ["python", "inference_v2.py", "--source", source_path, "--target", target_path, "--output", output_path]
    runtrain = ["python", "train.py", "--source", source_path, "--target", target_path, "--output", output_path, "--no-inference"]
    if not os.path.exists("/opt/micromamba/bin/micromamba"):
        if inference_flag:
            subprocess.run(runinference, check=True)
        else:
            subprocess.run(runtrain, check=True)

    # Call the voice cloning script
    if inference_flag:
        subprocess.run(runwithmicromamba + runinference, check=True)
    else:
        subprocess.run(runwithmicromamba + runtrain, check=True)
    if os.path.exists(output_path):
        print(f"Output file created at: {output_path}")
    else:
        print(f"Failed to create output file at: {output_path}")

# Start the serverless handler
runpod.serverless.start({"handler": handler})
