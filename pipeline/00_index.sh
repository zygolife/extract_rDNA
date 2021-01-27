#!/usr/bin/bash
#SBATCH -p short -N 1 -n 1

mkdir -p logs
module load bwa
module load samtools

DB=db/Coemansia_rDNA.fasta

if [ ! -f $DB.pac ]; then
  bwa index $DB
fi

if [ ! -f $DB.fai ]; then
  samtools faidx $DB
fi
