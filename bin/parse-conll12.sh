#!/bin/bash

# Requirements:
# - Download the Stanford parser: https://nlp.stanford.edu/software/lex-parser.shtml
# - Make sure you set the STANFORD_PARSER environment variable, e.g:
#     export STANFORD_PARSER="~/canvas/stanford-parser-full-2017-06-09"

STANFORD_CP="$STANFORD_PARSER/*:$STANFORD_POS/*:"
postagger_model="$STANFORD_POS/models/english-left3words-distsim.tagger"

dependencies_option="CCPropagatedDependencies" # "basic"

input_file=$1
output_dir=$2
input_file_nopath=${input_file##*/}

# Convert to one-sentence-per-line format and parse
awk '{print $4}' $input_file | awk '{if($1 == ""){print ""} else {printf "%s ", $0}} END {print ""}' | \
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
'BEGIN{s=0;c=0}{if(NF == 0){print ""; c=0; s++} else {print "conll05\t"s"\t"c++"\t"$1}}'
paste <(awk 'BEGIN{s=0;c=0} {if (substr($1,1,1) !~ /#/ && NF != 0) {print $1"\t"s"\t"$3"\t"$4"\t"$5} else {print ""; c=0; s++}}' $input_file) \
      <(awk '{if(NF == 0){print ""} else {print $5"\t"$7"\t"$8"\t_"}}' $f_parsed) \
      <(awk '{if (substr($1,1,1) !~ /#/ ) {print $0}}' $input_file | tr -s ' ' | cut -d' ' -f9- | sed 's/ /\t/g') \
> $f_combined
