#! /bin/tcsh

# sections that are considered to generate training data; section numbers should be sorted 
set SECTIONS = "02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21"


# if you feel that 4 sections is enough training data, use the following 
# set SECTIONS = "15 16 17 18"

# name of the output file 
set FILE = "train-set" 

foreach s ( $SECTIONS )

    echo Processing section $s

    zcat train/words/train.$s.words.gz > /tmp/$$.words
    zcat train/props/train.$s.props.gz > /tmp/$$.props

    ## Choose syntax
    # zcat train/synt.col2/train.$s.synt.col2.gz > /tmp/$$.synt
    # zcat train/synt.col2h/train.$s.synt.col2h.gz > /tmp/$$.synt
    # zcat train/synt.upc/train.$s.synt.upc.gz > /tmp/$$.synt
    # zcat train/synt.cha/train.$s.synt.cha.gz > /tmp/$$.synt
    
    # use gold syntax
    zcat train/synt/train.$s.synt.wsj.gz > /tmp/$$.synt

    zcat train/senses/train.$s.senses.gz > /tmp/$$.senses
    zcat train/ne/train.$s.ne.gz > /tmp/$$.ne

    paste -d ' ' /tmp/$$.words /tmp/$$.synt /tmp/$$.ne /tmp/$$.senses /tmp/$$.props | gzip > /tmp/$$.section.$s.gz
end

echo Generating gzipped file $FILE.gz
zcat /tmp/$$.section* | gzip -c > $FILE.gz

echo Cleaning files
rm -f /tmp/$$*

