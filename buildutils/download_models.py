from huggingface_hub import snapshot_download

# Download the entire OpenVoice repository or just the checkpoints
snapshot_download(
    repo_id="myshell-ai/OpenVoice",
    local_dir="checkpoints",  # where to save
    revision="main"           # branch or tag
)
