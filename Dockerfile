# syntax=docker/dockerfile:1.4

FROM mambaorg/micromamba:1.5.3

# Switch to root to install system build dependencies
USER root

ENV VOLUME_DIR="/runpod-volume/output"

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y \
        ffmpeg \
        build-essential \
        python3-dev \
        cmake \
    && rm -rf /var/lib/apt/lists/*

# Switch back to micromamba user
WORKDIR /app

# Copy your environment and code
COPY environment.yml requirements.txt ./
COPY . .

# Copy input and output folders
COPY ./input ./input
RUN mkdir -p ./output

# Create environment
RUN if [ -f environment.yml ]; then \
      micromamba create -y -n appenv -f environment.yml; \
    else \
      micromamba create -y -n appenv python=3.11; \
    fi \
 && micromamba clean -a -y

# Install pip-only dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    if [ -f requirements.txt ]; then \
      micromamba run -n appenv pip install --no-cache-dir -r requirements.txt; \
    fi

CMD ["micromamba", "run", "-n", "appenv", "python", "inference_v2.py", "--source", "./input/ref_audio_meme.wav", "--target", "./input/output_en_default.wav", "--output", $VOLUME_DIR]