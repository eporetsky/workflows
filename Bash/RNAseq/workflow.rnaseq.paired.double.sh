# $1 = experiment accession
# $2 = sample name
# $3 = fastq file 1
# $4 = md5 file 1
# $5 = fastq file 2
# $6 = md5 file 2
# $7 = genome index

# Function to calculate the MD5 checksum of the downloaded file

while true; do
    axel --quiet -n 8 -o ramdisk $3
    actual_md5=$(md5sum "ramdisk/$2_1.fastq.gz" | awk '{ print $1 }')
    if [ "$actual_md5" == "$4" ]; then
        break
    else
        rm ramdisk/$2_1.fastq.gz
    fi
done

while true; do
    axel --quiet -n 8 -o ramdisk $5
    actual_md5=$(md5sum "ramdisk/$2_2.fastq.gz" | awk '{ print $1 }')
    if [ "$actual_md5" == "$6" ]; then
        break
    else
        rm ramdisk/$2_2.fastq.gz
    fi
done


fastp --thread 15 --in1 ramdisk/$2_1.fastq.gz --out1 ramdisk/$2_1.fastq --in2 ramdisk/$2_2.fastq.gz --out2 ramdisk/$2_2.fastq --html $1/reports/fastp_$2.html

hisat2 -p 15 --min-intronlen 20 --max-intronlen 6000 -x $7 -1 ramdisk/$2_1.fastq -2 ramdisk/$2_2.fastq --summary-file $1/reports/hisat2_$2.txt | \
sambamba view -S -f bam -o /dev/stdout /dev/stdin | \
sambamba sort -F "not unmapped" --tmpdir="ramdisk/tmpmba" -t 15 -o ramdisk/$2.bam /dev/stdin

featureCounts -p -t exon,CDS -T 15 -a $7.gtf -o $1/counts/$2.counts ramdisk/$2.bam

samtools view -@ 15 -T $7.fa -C -o $1/crams/$2.cram ramdisk/$2.bam

rm ramdisk/$2*
