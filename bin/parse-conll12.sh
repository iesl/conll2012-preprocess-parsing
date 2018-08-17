#!/bin/bash

# Requirements:
# - Download the Stanford parser: https://nlp.stanford.edu/software/lex-parser.shtml
# - Make sure you set the STANFORD_PARSER environment variable, e.g:
#     export STANFORD_PARSER="~/canvas/stanford-parser-full-2017-06-09"

STANFORD_CP="$STANFORD_PARSER/*:$STANFORD_POS/*:"
postagger_model="$STANFORD_POS/models/english-left3words-distsim.tagger"

dependencies_option="CCPropagatedDependencies" # "basic"

input_file=$1

for file in `ls $input_dir`; do

    awk '{print $4}' $input_file | awk '{if($1 == ""){print ""} else {printf "%s ", $0}} END {print ""}' | \
    java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.parser.lexparser.LexicalizedParser \
    edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz \
    -sentences newline \
    -outputFormat typedDependenciesCollapsed \
    -tokenized \
    -

done

## First, convert the constituencies from the ontonotes files to the format expected
## by the converter
#for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
#    f_path=`sed 's|'${input_dir}'||' <<< $f`
#    f_prefix=${f_path%/*}
#    mkdir -p $output_dir/$f_prefix
#
#    echo "Extracting trees from: $f_path"
#    # word pos parse -> stick words, pos into parse as terminals
#    awk '{if (substr($1,1,1) !~ /#/ ) print $5" "$4"\t"$6}' $f | \
#    sed 's/\/\([.?-]\)/\1/' | \
#    sed 's/\(.*\)\t\(.*\)\*\(.*\)/\2(\1)\3/' > "$output_dir/$f_path.parse"
##    awk '{if(NF && substr($1,1,1) !~ /\(/){print "(TOP(INTJ(UH XX)))"} else {print}}' > "$f.parse"
#done
#
## Now convert those parses to dependencies
## Output will have the extension .sdeps
#for f in `find $input_dir/* -type f -not -path '*/\.*' -name "*_conll"`; do
#    f_path=`sed 's|'${input_dir}'||' <<< $f`
#    echo "Converting to dependencies: $f_path"
#    f=$output_dir/$f_path
#    java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.trees.EnglishGrammaticalStructure \
#    -treeFile "$f.parse" -$dependencies_option -conllx -keepPunct -makeCopulaHead > "$f.parse.sdeps"
#done

# Now assign auto part-of-speech tags
#for f in `find $input_dir/* -type f -not -path '*/\.*' -name "*_conll"`; do
#    f_path=`sed 's|'${input_dir}'||' <<< $f`
#    echo "POS tagging: $f_path"
#    f=$output_dir/$f_path
#    awk '{if(NF){printf "%s ", $2} else{ print "" }}' "$f.parse.sdeps" > "$f.parse.sdeps.posonly"
#    java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.tagger.maxent.MaxentTagger \
#        -model $postagger_model \
#        -textFile "$f.parse.sdeps.posonly" \
#        -tokenize false \
#        -outputFormat tsv \
#        -sentenceDelimiter newline \
#        > "$f.parse.sdeps.pos"
#done
#
## Finally, paste the original file together with the dependency parses and auto pos tags
#for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
#    f_path=`sed 's|'${input_dir}'||' <<< $f`
#    f_converted="$output_dir/$f_path.parse.sdeps"
#    f_pos="$output_dir/$f_path.parse.sdeps.pos"
#    f_combined="$output_dir/$f_path.combined"
#    paste <(awk '{if (substr($1,1,1) !~ /#/ ) {print $1"\t"$2"\t"$3}}' $f) \
#        <(awk '{print $2}' $f_converted) \
#        <(awk '{if (substr($1,1,1) !~ /#/ ) {print $5}}' $f) \
#        <(awk '{print $2}' $f_pos) \
#        <(awk '{if(NF == 0){print ""} else {print $7"\t"$8"\t_"}}' $f_converted) \
#        <(awk '{if (substr($1,1,1) !~ /#/ ) {print $0}}' $f | tr -s ' ' | cut -d' ' -f7- | sed 's/ /\t/g') \
#    > $f_combined
#done
