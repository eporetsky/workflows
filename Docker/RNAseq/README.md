This is a Docker container for analysis of RNA-seq short reads. In development, additional features will be added.

# Build the Docker container:
```
docker build --no-cache --rm -f Dockerfile -t externelly/plantapp:rnaseq .
```

# Run the docker container with a shared mount:
```
docker run -v ${PWD}/mount/:/mount --rm -it externelly/plantapp:rnaseq
```

# Creating a HISAT2 index for a reference genome

The `ref.fa` should be in the /mount folder, and will generate the `ref`.n.ht2 files. 
```
docker run -v ${PWD}/mount/:/mount externelly/plantapp:rnaseq /bin/bash -c "hisat2-build ref.fa ref"
```