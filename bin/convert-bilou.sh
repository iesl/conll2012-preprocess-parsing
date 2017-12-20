#!/bin/bash
#
# Converts the fields defined below in the given file (arg1) to BILOU format 
# from the CoNLL-2012 segment format.
#

input_file=$1

m=`awk '{print NF}' $input_file | sort -n | tail -1`; echo $m; start=15; l=`seq $start $m`;

max_field=`awk '{print NF}' $input_file | sort -n | tail -1`
first_field=14
fields_to_convert=`seq $first_field $(( max_field - 1 ))`

tmpfile=`mktemp`

bilou_file="$input_file.bilou"
cp $input_file $bilou_file

# Finally, paste the original file together with the dependency parses and auto pos tags
for field in $fields_to_convert; do
    echo "Converting field $field of $(( max_field - 1 ))"
    bin/convert-bilou-single-field.sh $bilou_file $field > $tmpfile
    cp $tmpfile $bilou_file
    #paste <(awk '{if (substr($1,1,1) !~ /#/ ) {print $1"\t"$2"\t"$3"\t"$4"\t"$5}}' $f) \
    #    <(awk '{print $2}' $f_pos) \
    #    <(awk '{print $6"\t"$7"\t"$9}' $f_converted) \
    #    <(awk '{if (substr($1,1,1) !~ /#/ ) {print $0}}' $f | tr -s ' ' | cut -d' ' -f7- | sed 's/ /\t/g') \
    #> "$input_file.bilou"
done

rm $tmpfile

