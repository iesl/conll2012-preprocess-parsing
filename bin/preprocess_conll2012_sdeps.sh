#!/bin/bash

STANFORD_CP="$STANFORD_PARSER/*:$STANFORD_POS/*:"
postagger_model="$STANFORD_POS/models/english-left3words-distsim.tagger"

dependencies_option="basic"

input_dir=$1
output_dir=$2

if [[ "$input_dir" =~ "dev" ]]; then
    data_split="dev"
elif [[ "$input_dir" =~ "test" ]]; then
    data_split="test"
elif [[ "$input_dir" =~ "train" ]]; then
    data_split="train"
else
    echo "Unable to match data split (train|dev|test) in path."
    exit
fi

output_dir=$output_dir/$data_split

# First, convert the constituencies from the ontonotes files to the format expected
# by the converter
for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
    f_path=`sed 's|'${input_dir}'||' <<< $f`
    f_prefix=${f_path%/*}
    mkdir -p $output_dir/$f_prefix

    echo "Extracting trees from: $f_path"
    # word pos parse -> stick words, pos into parse as terminals
    awk '{if (substr($1,1,1) !~ /#/ ) print $5" "$4"\t"$6}' $f | \
    sed 's/\/\([.?-]\)/\1/' | \
    sed 's/\(.*\)\t\(.*\)\*\(.*\)/\2(\1)\3/' > "$output_dir/$f_path.parse"
    # awk '{if(NF && substr($1,1,1) !~ /\(/){print "(TOP(INTJ(UH XX)))"} else {print}}' > "$f.parse"
done

# Now convert those parses to dependencies
# Output will have the extension .sdeps
for f in `find $input_dir/* -type f -not -path '*/\.*' -name "*_conll"`; do
    f_path=`sed 's|'${input_dir}'||' <<< $f`
    echo "Converting to dependencies: $f_path"
    f=$output_dir/$f_path
    java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.trees.EnglishGrammaticalStructure \
    -treeFile "$f.parse" -$dependencies_option -conllx -keepPunct -makeCopulaHead > "$f.parse.sdeps"
done

# Now assign auto part-of-speech tags
for f in `find $input_dir/* -type f -not -path '*/\.*' -name "*_conll"`; do
    f_path=`sed 's|'${input_dir}'||' <<< $f`
    echo "POS tagging: $f_path"
    f=$output_dir/$f_path
    awk '{if(NF){printf "%s ", $2} else{ print "" }}' "$f.parse.sdeps" > "$f.parse.sdeps.posonly"
    java -Xmx8g -cp $STANFORD_CP edu.stanford.nlp.tagger.maxent.MaxentTagger \
        -model $postagger_model \
        -textFile "$f.parse.sdeps.posonly" \
        -tokenize false \
        -outputFormat tsv \
        -sentenceDelimiter newline \
        > "$f.parse.sdeps.pos"
done

# Finally, paste the original file together with the dependency parses and auto pos tags
for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
    f_path=`sed 's|'${input_dir}'||' <<< $f`
    f_converted="$output_dir/$f_path.parse.sdeps"
    f_pos="$output_dir/$f_path.parse.sdeps.pos"
    f_combined="$output_dir/$f_path.combined"
    paste <(awk 'BEGIN{s=0} {if (substr($1,1,1) !~ /#/ && NF != 0) {print $1"\t"s"\t"$3}else {print ""; s++}}' $f) \
        <(awk '{print $2}' $f_converted) \
        <(awk '{if (substr($1,1,1) !~ /#/ ) {print $5}}' $f) \
        <(awk '{print $2}' $f_pos) \
        <(awk '{if(NF == 0){print ""} else {print $7"\t"$8"\t_"}}' $f_converted) \
        <(awk '{if (substr($1,1,1) !~ /#/ ) {print $0}}' $f | tr -s ' ' | cut -d' ' -f7- | sed 's/ /\t/g') \
    > $f_combined
done
