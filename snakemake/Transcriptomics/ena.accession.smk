# This snakemake workflow will download, trim, align, and count all FASTQ files from an ENA accession.
# Example call: snakemake -F -p -j1 --keep-going --snakefile all2counts_ena.smk --config sra=PRJNA385873 idx=ZmB73
# Optional for testing with small amount of reads add reads_to_process: --config rtp=10000
# Recommend, but not required, mounting ramdisk on the ramdisk folder: sudo mount -t tmpfs -o size=95000m tmpfs ramdisk/

import glob, os
import pandas as pd

os.makedirs("ramdisk", exist_ok = True)
os.makedirs("counts", exist_ok = True)
os.makedirs("crams", exist_ok = True)

def get_reports(acc):
    # Based on the EBI ENA tutorial on accessing their data
    # https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/file-reports.html
    res = "read_run"
    fie = "study_accession,tax_id,scientific_name,instrument_model,library_strategy,read_count,run_alias,sample_alias,fastq_ftp,fastq_md5"
    # Generate the url that will containt the study accession information once opened
    url="https://www.ebi.ac.uk/ena/portal/api/filereport?accession={0}&result={1}&fields={2}".format(acc, res, fie)
    # Open the URL with pandas and load it as a dataframe
    return pd.read_csv(url, sep="\t")

accession_df = get_reports(config['sra'])

# Might fail. For example, some expriments have both single- and pair-end samples.
fastq_type = "PAIRED" if len(accession_df["fastq_ftp"].values.tolist()[0].split(";")) == 2 else "SINGLE"

accession_dict = {}
SAMPLES = []
for key, val in accession_df[["run_accession", "fastq_ftp"]].values.tolist():
    accession_dict[key] = val.split(";")
    SAMPLES.append(key)

# If reads_to_process not defined, set to 0 to process all reads
try: rtp = config['rtp'] 
except: rtp=0

try: genome_index = config['idx']
except: genome_index = glob.glob("*.1.ht2")[0].replace(".1.ht2", "")

########################## Rules ###########################

rule all:
  input:
    # The snakemake workflow should include these files
    expand("counts/{sample}.counts.gz", sample=SAMPLES),
    expand("crams/{sample}.cram", sample=SAMPLES),

########################## Single-end ###########################

# Run fastp trimming on the fastq file
if fastq_type == "SINGLE":
  rule run_fastq:
    output:
      temp("ramdisk/{sample}.fastq.gz")
    params:
      ftp = lambda wc: accession_dict[wc.get("sample")][0],
    priority: 1
    run:
      shell("rm -f -r ramdisk/*")
      shell("axel --quiet -n 31 -o ramdisk {params.ftp}")

  # hisat2 runs faster when using non-compressed fastq files
  rule run_fastp:
    input:
      "ramdisk/{sample}.fastq.gz",
    output:
      temp("ramdisk/{sample}.fastq",)
      "reports/{sample}.html"
    params:
      rtp = rtp,
    priority: 2
    shell:
      """fastp\
      --reads_to_process {params.rtp}\
      --in1 {input} --out1 {output[0]}\
      --html {output[1]}
      --thread 16"""

  rule run_hisat2:
    input:
      "ramdisk/{sample}.fastq",
    output:
      "reports/hisat2_{sample}.txt",
      temp("ramdisk/{sample}.bam")
    params:
      idx = genome_index
    priority: 3
    shell:
      """hisat2 -p 31 --max-intronlen 6000 -x {params.idx} -U {input} --summary-file {output[0]} | \
      sambamba view -S -f bam -o /dev/stdout /dev/stdin | \
      sambamba sort -F "not unmapped" --tmpdir="tmpmba" -t 31 -o {output[1]} /dev/stdin
      """

  rule run_featureCounts:
    input:
        "ramdisk/{sample}.bam",
    output:
        "counts/{sample}.counts.gz",
        "crams/{sample}.cram",
    params:
        idx = genome_index,
        smpl = lambda wc: wc.get("sample"),
    priority: 4
    run:
        shell("featureCounts -t exon,CDS -T 31 -a {params.idx}.gtf -o counts/{params.smpl}.counts {input}")
        shell("gzip counts/{params.smpl}.counts")
        shell("samtools view -@ 31 -T {params.idx}.fa -C -o crams/{params.smpl}.cram {input}")

########################## Paired-end ###########################

if fastq_type == "PAIRED":
  rule run_fastq:
    output:
      temp("ramdisk/{sample}_1.fastq.gz"),
      temp("ramdisk/{sample}_2.fastq.gz"),
    params:
      ftp1 = lambda wc: accession_dict[wc.get("sample")][0],
      ftp2 = lambda wc: accession_dict[wc.get("sample")][1],
    priority: 1
    run:
      shell("axel --quiet -n 31 -o ramdisk {params.ftp1}") #--quiet
      shell("axel --quiet -n 31 -o ramdisk {params.ftp2}")

  # hisat2 runs faster when using non-compressed fastq files
  rule run_fastp:
    input:
      "ramdisk/{sample}_1.fastq.gz",
      "ramdisk/{sample}_2.fastq.gz",
    output:
      temp("ramdisk/{sample}_1.fastq"),
      temp("ramdisk/{sample}_2.fastq"),
      "reports/fastp_{sample}.html"
    params:
      rtp = rtp,
    priority: 2

    shell:
      """fastp\
      --reads_to_process {params.rtp}\
      --in1 {input[0]} --out1 {output[0]}\
      --in2 {input[1]} --out2 {output[1]}\
      --html {output[2]}\
      --thread 16"""
  
  rule run_hisat2:
    input:
      "ramdisk/{sample}_1.fastq",
      "ramdisk/{sample}_2.fastq",
    output:
      temp("ramdisk/{sample}.bam"),
      "reports/hisat2_{sample}.txt",
    params:
      idx = genome_index
    priority: 3
    shell:
      """hisat2 -p 31 --max-intronlen 6000 -x {params.idx} -1 {input[0]} -2 {input[1]} --summary-file {output[1]} | \
      sambamba view -S -f bam -o /dev/stdout /dev/stdin | \
      sambamba sort -F "not unmapped" --tmpdir="ramdisk/tmpmba" -t 31 -o {output[0]} /dev/stdin
      """

  rule run_featureCounts:
    input:
        "ramdisk/{sample}.bam",
    output:
        "counts/{sample}.counts.gz",
        "crams/{sample}.cram",
    params:
        idx = genome_index,
        smpl = lambda wc: wc.get("sample"),
    priority: 4
    run:
        shell("featureCounts -p -t exon,CDS -T 31 -a {params.idx}.gtf -o counts/{params.smpl}.counts {input}")
        shell("gzip counts/{params.smpl}.counts")
        shell("samtools view -@ 31 -T {params.idx}.fa -C -o {output[1]} {input}")