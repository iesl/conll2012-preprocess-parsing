#!/bin/bash

# You'll want to change this if you're not running from the project's root directory
CLEARNLP=`pwd`
CLEARLIB=$CLEARNLP/lib
CLASSPATH=$CLEARLIB/clearnlp-3.1.2.jar:$CLEARLIB/args4j-2.0.29.jar:$CLEARLIB/log4j-1.2.17.jar:$CLEARLIB/hppc-0.6.1.jar:$CLEARLIB/xz-1.5.jar:$CLEARLIB/clearnlp-dictionary-3.2.jar:$CLEARLIB/clearnlp-general-en-pos-3.2.jar:$CLEARLIB/clearnlp-global-lexica-3.1.jar:.

input_dir=$1
headrules=$CLEARNLP/headrule_en_stanford.txt
pos_config=$CLEARNLP/config_decode_pos.xml

# First, convert the constituencies from the ontonotes files to the format expected
# by the converter
for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
    echo "Extracting trees from: $f"
    # word pos parse -> stick words, pos into parse as terminals
    awk '{if (substr($1,1,1) !~ /#/ ) print $5" "$4"\t"$6}' $f | \
    sed 's/\(.*\)\t\(.*\)\*\(.*\)/\2(\1)\3/' | \
    awk '{if(NF && substr($1,1,1) !~ /\(/){print "(TOP(INTJ(UH XX)))"} else {print}}' > "$f.parse"
done

# Now convert those parses to dependencies
# Output will have the extension .dep
for f in `find $input_dir/* -type d -not -path '*/\.*'`; do
    echo "Converting to dependencies: $f"
    java -cp $CLASSPATH edu.emory.clir.clearnlp.bin.C2DConvert \
        -h $headrules \
        -i $f \
        -pe parse
done

# Now assign auto part-of-speech tags
# Output will have extension .cnlp
for f in `find $input_dir/* -type d -not -path '*/\.*'`; do
    echo "POS tagging: $f"
    java -cp $CLASSPATH edu.emory.clir.clearnlp.bin.NLPDecode \
        -mode pos \
        -c config_decode_pos.xml \
        -i $f \
        -ie dep
done

# Finally, paste the original file together with the dependency parses and auto pos tags
for f in `find $input_dir -type f -not -path '*/\.*' -name "*_conll"`; do
    f_converted="$f.parse.dep"
    f_pos="$f.parse.dep.cnlp"
    f_combined="$f_converted.combined"
    paste <(awk '{if (substr($1,1,1) !~ /#/ && (!NF || substr($6,1,1) ~ /\(/)) {print $1"\t"$2"\t"$3"\t"$4"\t"$5}}' $f) \
        <(awk '{print $2}' $f_pos) \
        <(awk '{print $6"\t"$7"\t"$9}' $f_converted) \
        <(awk '{if (substr($1,1,1) !~ /#/ ) {print $0}}' $f | tr -s ' ' | cut -d' ' -f7- | sed 's/ /\t/g') \
    > $f_combined
done
