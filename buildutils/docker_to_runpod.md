You have some repo containing everything needed to train, including data, utilities, environment stuff/dependencies and some kind of entry script. 
The process for using RunPod's resources to train it is like this:

Prepare Repo -> Recreate environment using Dockerfile -> Build Docker image + push to Docker Hub -> Create RunPod Serverless endpoint -> Attach image to container -> Run

# Steps #

## Preparing Repo + Docker Image##
You will have some repo containing model, data, etc. Your goal is train/inference/whatever on the GPU.

1. Freeze your python/conda environment
```
conda env export --no-builds > environment.yml 
pip freeze > requirements.txt   # if you used pip inside the env
```

2. Create a Dockerfile. 

This might take some experimentation, but this is what I ended up doing.

The idea behind this is using an already-prepared image that contains micromamba and some CUDA essentials so that you don't have to specify those. Then it gets system build dependencies (like cmake, python3-dev, etc) since a few packages I had needed them. Then it copies the repo with environment files, code, etc, and sets up the environment using requirements.txt + environment.yml. At the end you specify an ENTRYPOINT which is the base of the command you want to run once the container is created, and a CMD which can contain custom arguments to your ENTRYPOINT.

See for an example Dockerfile. https://github.com/notiesu/seed-vc/blob/main/Dockerfile
See https://github.com/notiesu/seed-vc/tree/main/buildutils for some Docker scripts that might be helpful.
  - dockerbuild.sh {VERSION_NUMBER} {--write-to-cache}
    - Builds your docker image. Look at the script and change to match your configurations.
    - VERSION_NUMBER: specify a version number, appends to the tag of your Docker image.
    - --write-to-cache: caches buildfiles, this build may take longer but subsequent builds will be faster.
  -dockertest.sh {VERSION_NUMBER}
    -VERSION_NUMBER: specify a version number of your image to run
  - dockerclean.sh
    -Cleans some unused docker stuff, I would look into the script to make sure it doesn't delete everything

Some tips:
--mount=type=cache significantly reduces build times by caching dependencies.
docker rmi $IMAGE_ID_OR_NAME$ gets rid of an image - you can do this once you pushed to docker hub in step 3
Use CMD at the end to pass your output parameters - you will want to output to /runpod-volume to get output into your network volume

3. Build docker image (replace $VARIABLES$ with whatever it says or use dockerbuild.sh from https://github.com/notiesu/seed-vc/tree/main/buildutils)
Dont forget your username as a prefix - you might run into access issues if you dont put it
```
docker buildx build -t $YOUR_DOCKER_USERNAME$/$YOUR_REPO_NAME$:$VERSION_TAG$ .
```


4. Test changes locally with CPU (or use dockertest.sh from https://github.com/notiesu/seed-vc/tree/main/buildutils)
```
docker run --rm -it $YOUR_DOCKER_USERNAME$/$YOUR_REPO_NAME$:$VERSION_TAG$ -c "$YOUR_ENTRY_COMMAND_IF_YOU_NEED$"
```

5. Push to docker hub
```
docker push $YOUR_DOCKER_USERNAME$/$YOUR_REPO_NAME$:$VERSION_TAG$
```
## Attaching a Volume ##

You need a network volume to get the results of your training/inference/whatever. This is just an s3 bucket that your container has access to and you can put your outputs in.

See https://docs.runpod.io/serverless/storage/network-volumes for more.

1. From the left menu, go to "Storage" -> "New Network Volume" -> "US-CA-2" 
  -we use US-CA-2 since it has S3 compatibility while others dont 

2. Name it, pick size, and go to "Create Network Volume"

3. Go back to "Storage" -> "Create S3 API Key"

4. Name your key, and save your private key somewhere

You will attach this volume in your runpod serverless setup


## RunPod Serverless Setup ##

1. Go here to set up a RunPod account + put some money in - https://www.runpod.io/

2. Go to "Serverless" on the left hand side menu -> "+New Endpoint"

3. Go to "Import From Docker Registry" below the connecting to Github account prompt

4. Use your image by putting in docker.io/library/$YOUR_DOCKER_USERNAME$/$YOUR_REPO_NAME$:$VERSION_TAG$

5. Configure with whatever you need

6. Go to "Edit Endpoint" -> "Advanced" -> Select the network volume you created before -> "Save changes"

7. Go to the "Requests" tab and press the RunSync button to run your first job

## Check for Success ##
1. Check logs for return 0s - this means your job completed with no errors

2. Go to "Storage" -> the network volume you used -> copy the S3 API access command

3. Run the command in your terminal (you may have to install s3-cli) - check if your output is there

### IMPORTANT - FRUGALITY!!###
I'm seeing problems where they are charging me even if there is no job in the queue. To play it safe, this is what worked for me to not get charged while I wasn't using the endpoint

1. Go to "Manage" -> "Edit Endpoint"

2. Scale Max Workers to 0 when not in use

If you see any other way to save money on this please say so thanks

