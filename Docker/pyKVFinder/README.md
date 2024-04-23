This Docker container runs [pyKVFinder](https://lbc-lnbio.github.io/pyKVFinder/), a method for cavity detection and characterization.

Build the Docker container:
```
docker build --rm -f Dockerfile -t ubuntu:pyKVFinder .
```

Run the docker container with a shared PDB mount:
```
docker run --name=pyKVFinder -v ${PWD}/mount:/mount --rm -it ubuntu:pyKVFinder
# To use sudo, the password is `password`
```

Once you start running the Docker container, your commandline should be redirected to the Docker terminal. From there you can run the different packages mentioned below. The mount/pdb/ directory found in the current directory is mounted with the image to have persistant access with the Docker environment. When using the Docker commandline, you can read and write all files in the /mount folder.

This is Docker image is based on the template image found here: https://github.com/maliksahil/docker-ubuntu-sahil
