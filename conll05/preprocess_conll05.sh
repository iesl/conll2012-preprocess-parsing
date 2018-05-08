#!/bin/bash

# You'll want to change this if you're not running from the project's root directory
CLEARNLP=`pwd`
CLEARLIB=$CLEARNLP/lib
CLASSPATH=$CLEARLIB/clearnlp-3.1.2.jar:$CLEARLIB/args4j-2.0.29.jar:$CLEARLIB/log4j-1.2.17.jar:$CLEARLIB/hppc-0.6.1.jar:$CLEARLIB/xz-1.5.jar:$CLEARLIB/clearnlp-dictionary-3.2.jar:$CLEARLIB/clearnlp-general-en-pos-3.2.jar:$CLEARLIB/clearnlp-global-lexica-3.1.jar:.

input_file=$1
headrules=$CLEARNLP/headrule_en_stanford.txt
pos_config=$CLEARNLP/config_decode_pos.xml

# First, convert the constituencies from the ontonotes files to the format expected
# by the converter
echo "Extracting trees from: $input_file"
# word pos parse -> stick words, pos into parse as terminals
zcat $input_file | \
awk 'gsub(/\(/, "-LRB-", $2); gsub(/\)/, "-RRB-", $2); print $2" "$1"\t"$3}' | \
sed 's/\(.*\)\t\(.*\)\*\(.*\)/\2(\1)\3/' > "$input_file.parse"

# Now convert those parses to dependencies
# Output will have the extension .dep
echo "Converting to dependencies: $input_file.parse"
java -cp $CLASSPATH edu.emory.clir.clearnlp.bin.C2DConvert \
    -h $headrules \
    -i "$input_file.parse" \
    -pe parse

# Now assign auto part-of-speech tags
# Output will have extension .cnlp
echo "POS tagging: $input_file.parse.dep"
java -cp $CLASSPATH edu.emory.clir.clearnlp.bin.NLPDecode \
    -mode pos \
    -c config_decode_pos.xml \
    -i "$input_file.parse.dep" \
    -ie dep

# Finally, paste the original file together with the dependency parses and auto pos tags
f_converted="$input_file.parse.dep"
f_pos="$input_file.parse.dep.cnlp"
f_combined="$f_converted.combined"
paste <(zcat $input_file | awk '{if(NF == 0){print ""} else {print "_\t_\t_\t"$1"\t"$2}}' ) \
    <(awk '{print $2}' $f_pos) \
    <(awk '{print $6"\t"$7"\t"$9}' $f_converted) \
    <(zcat $input_file | awk '{if(NF == 0){print ""} else {print $5"\t"$6"\t-\t-\t"$4}}' ) \
    <(zcat $input_file | awk '{if(NF == 0){print ""} else {print $0"\t_"}}' | tr -s ' ' | cut -d' ' -f7- | sed 's/ /\t/g') \
> $f_combined
