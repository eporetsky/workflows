This Docker container contains a collection of packages that can be used to calculate different physiochemical features of proteins and protein residues from a PDB structure file. 

Build the Docker container:
```
docker build --rm -f Dockerfile -t ubuntu:pdb_feat .
```

Run the docker container with a shared PDB mount:
```
docker run --name=pdb_feat -v ${PWD}/mount/pdb:/mount --rm -it ubuntu:pdb_feature
```

Once you start running the Docker container, your commandline should be redirected to the Docker terminal. From there you can run the different packages mentioned below. The mount/pdb/ directory found in the current directory is mounted with the image to have persistant access with the Docker environment. When using the Docker commandline, you can read and write all files in the /mount folder.

The following packages are currently available with this Docker container:
* freesasa v2.1.2

This is Docker image is based on the template image found here: https://github.com/maliksahil/docker-ubuntu-sahil
