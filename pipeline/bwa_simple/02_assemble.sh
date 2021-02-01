#!/usr/bin/bash
#SBATCH --out logs/spades.%a.log -N 1 -n 16 --mem 16gb -p short

module load SPAdes/3.14.1
MEM=16
SAMPLEFILE=samples.csv
DB=db/Coemansia_rDNA.fasta
DBNAME=$(basename $DB .fasta)
TMP=/scratch
ASMDIR=asm
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

if [ ! -f $ASMDIR/${INFILE}.$DBNAME/scaffolds.fasta ]; then
  spades.py --isolate -m $MEM -t $CPU --trusted-contigs $DB -o $ASMDIR/${INFILE}.$DBNAME --merged $EXTRACT/${INFILE}.$DBNAME.pe.fq  -s $EXTRACT/${INFILE}.$DBNAME.s.fq
fi
