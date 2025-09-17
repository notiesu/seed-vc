# syntax=docker/dockerfile:1.4

FROM mambaorg/micromamba:1.5.3

# Switch to root to install system build dependencies, give mambauser access to volume dir
USER root

ENV VOLUME_DIR="/runpod-volume"
ENV PATH=/opt/conda/bin:$PATH

RUN mkdir -p ${VOLUME_DIR} && chown -R mambauser ${VOLUME_DIR}

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y \
        ffmpeg \
        build-essential \
        python3-dev \
        cmake \
    && rm -rf /var/lib/apt/lists/*

# Copy environment and code with correct ownership
COPY --chown=mambauser:mambauser environment.yml requirements.txt ./
COPY --chown=mambauser:mambauser . .

# Create input/output dirs
RUN mkdir -p ./input ./output

# Create environment
RUN if [ -f environment.yml ]; then \
      micromamba create -y -n appenv -f environment.yml; \
    else \
      micromamba create -y -n appenv python=3.11; \
    fi \
 && micromamba clean -a -y

# Ensure mamba cache exists
RUN mkdir -p /home/mambauser/.cache/mamba \
    && chown -R mambauser:mambauser /home/mambauser/.cache/mamba

# Install pip-only dependencies
RUN --mount=type=cache,target=/home/mambauser/.cache/pip \
    --mount=type=cache,target=/home/mambauser/.cache/mamba \
    if [ -f requirements.txt ]; then \
      micromamba run -n appenv pip install --no-cache-dir -r requirements.txt; \
    fi

# Entrypoint

ENTRYPOINT ["micromamba", "run", "-n", "appenv", "python", "inference_v2.py"]
CMD ["--source", "./input/ref_audio_meme.wav", "--target", "./input/output_en_default.wav", "--output", "/runpod-volume"]
