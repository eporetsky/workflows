This Docker container runs [AlphaFill](https://github.com/PDB-REDO/alphafill/), a method for transplanting missing cofactors and molecules from experimental PDB structures to predicted structures.

Build the Docker container:
```
docker build --rm -f Dockerfile -t ubuntu:AlphaFill .
```

Run the docker container with a shared PDB mount:
```
docker run --name=AlphaFill -v ${PWD}/:/input --rm -it ubuntu:AlphaFill
```

Once you start running the Docker container, your commandline should be redirected to the Docker terminal. From there you can run the different packages mentioned below. The current directory is mounted with the container `/input` folder to have persistant access with the Docker environment. When using the Docker commandline, you can read and write all files in the `/input` folder.

The AlphaFill documentation is somewhat lacking so I will try to add some relevant information:
* The AlphaFill installation does not automatically download the  PDB-REDO database that AlphaFill uses to extract information from. If you want the complete database, I recommend downloading it seperately since it might take a couple of hours and I read that it weighs over 1TB. Use the following command to download the [PDB-REDO](https://pdb-redo.eu/download) database `rsync -av --exclude=attic rsync://rsync.pdb-redo.eu/pdb-redo/ pdb-redo/`
* If you want to make additional edits to the config file, you can find it at `/usr/local/etc/alphafill.conf`
* AlphaFill seems to work only with CIF formatted files for both input and output.
* A more managable solution is to build a custom database of select PDB-REDO files. I will write a longer post about it but the basic idea is if you are dealing with a specific family of proteins, you can extract a subet of PDB IDs from UniProt that share PFAM/InterProScan domains and use these PDBs to make a custom database. NOTE: To build a custom AlphaFill database, you need to save the PDB-REDO files into a folder formatted as `pdb-redo/pdb_id[1:3]/pdb_id/pdb_id_final.cif`:
```
# This will create a proprely formatted format that works with the 'alphafill create-index' command
for pdb_id in pdb_list:
    os.makedirs('pdb-redo/00/{}'.format(pdb_id), exist_ok=True)
    os.system("wget https://pdb-redo.eu/db/{}/{}_final.cif --directory-prefix pdb-redo/{}/{}".format(pdb_id, pdb_id, pdb_id[1:3], pdb_id))
```

Finally, after all the PDB-REDO files have been downloaded and you have a pdb-redo folder, you can generate the fasta index and run the AlphaFill pipeline with the following commands:
```
# Assumes a /input/pdb-redo folder with PDB-REDO files exists
alphafill create-index

# The AlphaFill output CIF will be found at: input/filled/
alphafill process input/cifs/af2_struct.cif input/filled/af2_struct.cif
```

Enjoy transplanting!