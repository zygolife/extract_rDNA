#!/usr/bin/bash
#SBATCH --out logs/bwa.%a.log -N 1 -n 16 --mem 8gb -p short

module load samtools
module load bwa

SAMPLEFILE=samples.csv
DB=db/Coemansia_rDNA.fasta
DBNAME=$(basename $DB .fasta)
TMP=/scratch
EXT=bam
INDIR=input
OUTDIR=aln
EXTRACT=extracted
mkdir -p $OUTDIR $EXTRACT
CPU=$SLURM_CPUS_ON_NODE
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

INFILE=$(sed -n ${N}p $SAMPLEFILE)


if [ ! -f $OUTDIR/${INFILE}.$DBNAME.bam ]; then
#  $TMP/${INFILE}.$DBNAME.sam
#   -o $TMP/${INFILE}.$DBNAME.sam
  bwa mem -t $CPU -U 0 -L 1,1 -B 2 -S $DB $INDIR/${INFILE}_R?.fq.gz | samtools sort -O bam --threads 2 -o $OUTDIR/${INFILE}.${DBNAME}.bam
#  unlink $TMP/${INFILE}.$DBNAME.sam
fi

if [[ -f $OUTDIR/${INFILE}.$DBNAME.bam && ! -f $EXTRACT/${INFILE}.$DBNAME.s.fq ]]; then
  samtools fastq -F 4 --threads $CPU -N -o $EXTRACT/${INFILE}.$DBNAME.pe.fq  -s $EXTRACT/${INFILE}.$DBNAME.s.fq $OUTDIR/${INFILE}.$DBNAME.bam
fi
