#!/bin/bash

## convert spos.conllu  data to 15 column tsv format

if [ "$#" -ne 1 ]; then
  echo "Must supply input directory containing  wsj\*sdep.spos.conllu files."
  exit 1
fi

in_dir=$1
out_dir="${in_dir}/bio_format"
mkdir -p $out_dir

for in_f in wsj02-21-trn.sdep.spos.conllu wsj22-dev.sdep.spos.conllu wsj23-tst.sdep.spos.conllu;
do
  awk -F $'\t' '{\
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
    "-", "-", ($1-1), $2, $5, $4, $7, $8, "-", "-", "-", "-", "-", "*", "-"\
  }' $in_dir/$in_f > ${out_dir}/${in_f}_BIO
done
