#!/usr/bin/bash
#SBATCH --out logs/aTRAM_build.%a.log -N 1 -n 4 --mem 4gb -p short

module load atram
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
  CPU=1
fi

SAMPLEFILE=samples.csv
INDIR=input
OUTDIR=aTRAM_db
mkdir -p $OUTDIR
DB=db/Coemansia_rDNA.fasta
TMP=/scratch

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

INFILE=$(sed -n ${N}p $SAMPLEFILE)

if [ ! -s $OUTDIR/${INFILE}.sqlite.db ]; then
  atram_preprocessor.py --gzip --blast-db $OUTDIR/${INFILE} --end-1=$INDIR/${INFILE}_R1.fq.gz --end-2=$INDIR/${INFILE}_R1.fq.gz  --fastq -l logs/aTRAM_build.$INFILE.preprocess.log --cpus $CPU -t $TMP
fi
