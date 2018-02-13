#!/usr/bin/env bash
#
# Convert the Penn TreeBank to Stanford dependencies
# https://nlp.stanford.edu/software/stanford-dependencies.html
#

path_to_stanford_parser=/iesl/canvas/strubell/stanford-parser-full-2017-06-09
PTB=/iesl/data/ptb/v1/combined/wsj

declare -a train=(02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21)
declare -a dev=(22)
declare -a test=(23)
declare -a altdev=(24)

output_dir="wsj-parse-3.5.0"
mkdir -p $output_dir

train_output="$output_dir/wsj02-21-trn.sdep"
dev_output="$output_dir/wsj22-dev.sdep"
test_output="$output_dir/wsj23-tst.sdep"
altdev_output="$output_dir/wsj24-altdev.sdep"

# make sure output files are empty
cat /dev/null > $train_output
cat /dev/null > $test_output
cat /dev/null > $dev_output
cat /dev/null > $altdev_output

#for sec in ${train[@]}
#  do
#  dir=$PTB/$sec
#  for f in $dir/*
#  do
#    echo "Writing $f to $train_output..."
#    java -mx150m -cp "$path_to_stanford_parser/*:" edu.stanford.nlp.trees.EnglishGrammaticalStructure \
#        -treeFile $f -basic -conllx -keepPunct -makeCopulaHead >> $train_output
#  done
#done

for sec in ${test[@]}
  do
  dir=$PTB/$sec
  for f in $dir/*
  do
    echo "Writing $f to $test_output ..."
    java -mx150m -cp "$path_to_stanford_parser/*:" edu.stanford.nlp.trees.EnglishGrammaticalStructure \
        -treeFile $f -basic -conllx -keepPunct -makeCopulaHead >> $test_output
  done
done

for sec in ${dev[@]}
do
  dir=$PTB/$sec
  for f in $dir/*
  do
    echo "Writing $f to $dev_output ..."
    java -mx150m -cp "$path_to_stanford_parser/*:" edu.stanford.nlp.trees.EnglishGrammaticalStructure \
        -treeFile $f -basic -conllx -keepPunct -makeCopulaHead >> $dev_output
  done
done

for sec in ${altdev[@]}
do
  dir=$PTB/$sec
  for f in $dir/*
  do
    echo "Writing $f to $altdev_output ..."
    java -mx150m -cp "$path_to_stanford_parser/*:" edu.stanford.nlp.trees.EnglishGrammaticalStructure \
        -treeFile $f -basic -conllx -keepPunct -makeCopulaHead >> $altdev_output
  done
done
