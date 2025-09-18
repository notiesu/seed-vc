import runpod
import os

def handler(job):
    # Get the input from the job
    job_input = job["input"]
    
    # Expecting the output_dir to be passed in the job input
    output_dir = job_input.get("output_dir")
    if not output_dir:
        return {"status": "error", "message": "No output_dir provided"}

    output_file = os.path.join(output_dir, "output.wav")

    # Check if the file exists
    if os.path.exists(output_file):
        return {"status": "success", "output_path": output_file}
    else:
        return {"status": "error", "message": f"{output_file} not found"}

# Start the serverless handler
runpod.serverless.start({"handler": handler})
