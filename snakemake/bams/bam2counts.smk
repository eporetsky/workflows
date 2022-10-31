import glob, os
import pandas as pd

########################## Conda environment ###########################
# conda config --add channels conda-forge
# conda install genozip
# conda install -c conda-forge libgcc-ng=11.2.0
# conda install -c bioconda fastp=0.23.2
# conda install -c bioconda hisat2=2.2.1
# conda install -c bioconda sambamba=0.8.2
# conda install -c bioconda parallel-fastq-dump
# conda install -c conda-forge genozip
# conda install -c bioconda subread=2.0.1

########################## Globals ###########################
# genome_index_name: I renamed the hisat2, gtf and genozip genome files to the genome_index_name+suffix
# All these files are contained in the global folder

########################## Running workflow ###########################
# By default, all fastq files to analyze should be copied to the "fastq" folder at the same level as the "ramdisk" folder
# For RNAseq workflow testing change the fastp --reads_to_process to
# a small number (10000) for faster and simpler workflow testing (only applies to fastp, not download step)

# To prolong the life of the hard-drive I recommend to mount ramdisk on the "folder" variable (SRA project name)
# sudo mount -t tmpfs -o size=95000m tmpfs ramdisk/

# To run this snakemake workflow use:
# bam:     snakemake -p -j1 --keep-going --snakefile fastq2counts.smk --config sp=PAIRED type=bam idx=ref_id
# genozip: snakemake -p -j1 --keep-going --snakefile fastq2counts.smk --config sp=PAIRED type=genozip idx=ref_id

# Need to know if SINGLE- or PAIRED-END for featureCounts
fastq_type = config['sp']
if fastq_type == "PAIRED":
  fastq_type = "-p"
elif fastq_type == "SINGLE":
  fastq_type = ""
else:
  fastq_type = "wrong"

bam_type = config['type']

if bam_type == "genozip":
  SAMPLES = [fl.replace(".bam.genozip","").replace("bams/","") for fl in glob.glob("bams/*.genozip")]
elif bam_type == "bam":
  SAMPLES = [fl.replace(".bam","").replace("bams/","") for fl in glob.glob("bams/*.bam")]

genome_index = "global/"+config['idx']


########################## Rules ###########################

rule all:
  input:
    # The snakemake workflow should include these files
    expand("counts/{sample}.counts.gz", sample=SAMPLES),

if bam_type == "bam":
  rule run_featureCounts:
    input:
        "bams/{sample}.bam.genozip",
    output:
        "counts/{sample}.counts.gz",
    params:
        sp = fastq_type,
        idx = genome_index,
        smpl = lambda wc: wc.get("sample"),
    priority: 1
    run:
        shell("featureCounts {params.sp} -t exon,CDS -T 32 -a {params.idx}.gtf -o counts/{params.smpl}.counts {input}")
        shell("gzip counts/{params.smpl}.counts")

if bam_type == "genozip":
  rule run_featureCounts:
    input:
        "bams/{sample}.bam.genozip",
    output:
        "counts/{sample}.counts.gz",
    params:
        sp = fastq_type,
        idx = genome_index,
        smpl = lambda wc: wc.get("sample"),
    priority: 1
    run:
        shell("genounzip --force --reference {params.idx}.ref.genozip {input} --output ramdisk/{params.smpl}.bam")        
        shell("featureCounts {params.sp} -t exon,CDS -T 32 -a {params.idx}.gtf -o counts/{params.smpl}.counts ramdisk/{params.smpl}.bam")
        shell("gzip counts/{params.smpl}.counts")
        shell("rm ramdisk/{params.smpl}.bam")