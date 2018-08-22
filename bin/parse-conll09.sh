#!/bin/bash

# Requirements:
# - Download the Stanford parser: https://nlp.stanford.edu/software/lex-parser.shtml
# - Make sure you set the STANFORD_PARSER environment variable, e.g:
#     export STANFORD_PARSER="$HOME/canvas/stanford-parser-full-2017-06-09"
# - This script expects that you have already created $output_dir, and will fail otherwise


STANFORD_CP="$STANFORD_PARSER/*:"

dependencies_option="CCPropagatedDependencies" # "basic"

input_file=$1
output_dir=$2
input_file_nopath=${input_file##*/}

# Convert to one-sentence-per-line format and parse
awk '{print $2}' $input_file | awk '{if($1 == ""){print ""} else {printf "%s ", $0}} END {print ""}' | \
java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.parser.lexparser.LexicalizedParser \
-sentences newline \
-outputFormat penn \
-tokenized \
-originalDependencies \
edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz \
- > $output_dir/$input_file_nopath.trees

# Convert parses to dependencies
java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.trees.EnglishGrammaticalStructure \
-$dependencies_option \
-conllx \
-treeFile $output_dir/$input_file_nopath.trees \
> $output_dir/$input_file_nopath.deps

# Finally, paste the original file together with the dependency parses and auto pos tags
f_parsed="$output_dir/$input_file_nopath.deps"
f_combined="$output_dir/$input_file_nopath.parsed"
paste <(awk 'BEGIN{s=0} {if (NF != 0) {print $1"\t"$2"\t"$3"\t"$4"\t"$5} else {print ""; s++}}' $input_file) \
      <(awk '{if(NF == 0){print ""} else {print $5"\t"$6"\t"$7"\t"$8}}' $f_parsed) \
      <(awk '{if(NF == 0){print ""}}' $input_file | tr -s ' ' | cut -d' ' -f8- | sed 's/ /\t/g') \
> $f_combined
