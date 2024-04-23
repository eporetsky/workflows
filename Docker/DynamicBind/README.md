This Docker container runs [DynamicBind](https://github.com/luwei0917/DynamicBind/).

Note: I didn't have the chace to test if DynamicBind itself runs properly in this environment but I the installation itself seems to complete succesfully. 

Build the Docker container:
```
docker build --rm -f Dockerfile -t ubuntu:DynamicBind .
```

Run the docker container with a shared PDB mount:
```
docker run --shm-size 8G --gpus all -it -v ${PWD}:/workspace/DynamicBind ubuntu:DynamicBind /bin/bash
# ${PWD} on windows/$PWD for linux 
```

Once you start running the Docker container, your commandline should be redirected to the Docker terminal. From there you can run the different packages mentioned below. The current directory is mounted to the /DynamicBind/input directory in the container image for persistant access with the Docker environment.

The Docker container is not complete yet. The following lines need to run from inside the image terminal :


```
# Fix error with the conda dynamicbind env
cd DynamicBind
conda activate dynamicbind
pip install -U numpy

# Download the workdir from zenodo
apt-get install wget unzip
wget https://zenodo.org/records/10137507/files/workdir.zip?download=1
mv workdir.zip\?download\=1 workdir.zip
unzip workdir.zip
python run_single_protein_inference.py input/protein.pdb input/ligand.csv --paper --results . --python /opt/conda/envs/dynamicbind/bin/python --relax_python /opt/conda/envs/relax/bin/python

# Finally copy the results to the input/ folder
mv test/ input/
```

### TODO

* Combine the above code into the docker container.
* Test that everything works