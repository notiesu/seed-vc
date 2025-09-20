import runpod
import os
import subprocess

def handler(job):
    # Get the input from the job
    input = job.get("input", {})
    source_path = input.get("source_path")
    target_path = input.get("target_path")
    output_path = input.get("output_path")
    checkpt_path = input.get("checkpt_path", None)
    config_path = input.get("config_path", None)
    inference_flag = input.get("inference_flag")
    training_data = input.get("training_data", None)

    # Expecting the output_dir to be passed in the job input
    print(f"source_path: {source_path}")
    print(f"target_path: {target_path}")
    print(f"output_path: {output_path}")

    #check for micromamba installation
    runwithmicromamba = ["micromamba", "run", "-n", "appenv"]
    runinference = ["./api-inference.sh", "--source", source_path, "--target", target_path, "--output", output_path]
    runtrain = ["./api-train.sh", "--data-dir", training_data, "--run-name", "testrun"]
    if checkpt_path:
        runinference += ["cfm-checkpoint-path", checkpt_path]
    if config_path:
        runinference += ["--config", config_path]
    if not os.path.exists("/opt/micromamba/bin/micromamba"):
        if inference_flag:
            subprocess.run(runinference, check=True)
        else:
            subprocess.run(runtrain, check=True)

    # Call the voice cloning script
    if inference_flag:
        subprocess.run(runwithmicromamba + runinference, check=True)
    else:
        subprocess.run(runtrain, check=True)
    
    if os.path.exists(output_path):
        print(f"Output file created at: {output_path}")
    else:
        print(f"Failed to create output file at: {output_path}")

# Start the serverless handler
runpod.serverless.start({"handler": handler})
