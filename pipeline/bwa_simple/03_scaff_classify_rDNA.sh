#  echo blastn -num_threads $CPU -query $QFILE
#  echo $sp

#!/usr/bin/bash
#SBATCH -p short -N 1 -n 2 --mem 8gb --out logs/classify_rDNA_sort.log

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
  CPU=1
fi
module load ncbi-blast/2.9.0+
module load ragtag
source activate ragtag

INDIR=asm
OUTDIR=asm_scaf
mkdir -p $OUTDIR
DB=db/Coemansia_rDNA.fasta
if [ ! -s $DB.nsq ]; then
  makeblastdb -dbtype nucl -in $DB -parse_seqids
fi
for sp in $(ls $INDIR)
do
  SCF=$INDIR/$sp/scaffolds.fasta
  CTG=$INDIR/$sp/contigs.fasta
  if [ -d $INDIR/$sp ]; then
    QFILE=$INDIR/$sp/scaffolds.fasta
    if [ -s $SCF ]; then
      echo "scaffolds file $sp"
      QFILE=$SCF
    elif [ -s $CTG ]; then
      echo "contigs file for $sp"
      QFILE=$CTG
    else
      echo "No scaffolds or contigs for $sp"
      QFILE=""
      continue
    fi
  fi
  pushd $OUTDIR
  ragtag.py scaffold -u -o ${sp} ../db/Coemansia_rDNA.consensi.fasta ../$QFILE
  popd
done
