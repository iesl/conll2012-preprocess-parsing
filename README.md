# conll2012-preprocess-parsing
Scripts for pre-processing the CoNLL-2012 dataset for syntactic dependency parsing.

These scripts attempt to replicate the pre-processing of the [CoNLL-2012 subset](http://conll.cemantix.org/2012/data.html) of the OntoNotes corpus described in the paper 
[It Depends: Dependency Parser Comparison Using A Web-based Evaluation Tool](http://www.aclweb.org/anthology/P/P15/P15-1038.pdf).

Specifically, they use [ClearNLP](https://github.com/clir/clearnlp) to (1) convert the
constituency parses to dependency structure (w/ head rules [described here](http://www.mathcs.emory.edu/~choi/doc/cu-2012-choi.pdf) 
and (2) assign automatic part-of-speech tags.

The scripts assume you have already extracted the CoNLL-2012 split from the OntoNotes corpus, [as described here](http://conll.cemantix.org/2012/data.html).

Note that these scripts *do not* remove length-1 sentences, as was done in the paper cited above. We leave you to do that if you choose.

Requirements
--------------
- I ran these with Java 8

Currently these scripts write to the `/path/to/conll-2012` directories below. Happy to accept patches that will write files to
somewhere else.

Download ClearNLP
--------------
```
./bin/download_clearNLP.sh
```

Do the pre-processing
--------------
```
./bin/preprocess_conll2012.sh /path/to/conll-2012/dev
./bin/preprocess_conll2012.sh /path/to/conll-2012/test
./bin/preprocess_conll2012.sh /path/to/conll-2012/train
```

Combine into single files
--------------
```
for f in `find /path/to/conll-2012/train -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-train.txt; done
for f in `find /path/to/conll-2012/dev -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-dev.txt; done
for f in `find /path/to/conll-2012/test -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-test.txt; done
```

Convert segments to BILOU encoding
-------------
```
./bin/convert-bilou.sh /path/to/file
```

Extracting props
-------------
This is useful for producing the gold file expected for `srl-eval.pl`
```
python bin/extract_conll_prop_file.py --input_file /path/to/conll2012-test.txt --word_field 3 --first_prop_field 14 --pred_field 9
```

File format
-------------
TODO describe
```
nw/wsj/24/wsj_2437      0       0       For     IN      IN      7       prep    _       -       -       -       -       *       (ARGM-TMP*      -
nw/wsj/24/wsj_2437      0       1       all     DT      DT      1       pobj    _       -       -       -       -       *       *       (0)
nw/wsj/24/wsj_2437      0       2       of      IN      IN      2       prep    _       -       -       -       -       *       *       (0
nw/wsj/24/wsj_2437      0       3       1988    CD      CD      3       pobj    _       -       -       -       -       (DATE)  *)      (0)|0)
nw/wsj/24/wsj_2437      0       4       ,       ,       ,       7       punct   _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       5       Dassault        NNP     NNP     7       dep     _       -       -       -       -       (ORG)   (ARG0*) (1)
nw/wsj/24/wsj_2437      0       6       had     VBD     VBD     0       root    _       have    03      1       -       *       (V*)    -
nw/wsj/24/wsj_2437      0       7       group   NN      NN      9       compound        _       group   -       -       -       *       (ARG1*  (1)
nw/wsj/24/wsj_2437      0       8       profit  NN      NN      7       dobj    _       profit  -       1       -       *       *       -
nw/wsj/24/wsj_2437      0       9       of      IN      IN      9       prep    _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       10      428     CD      CD      12      compound        _       -       -       -       -       (MONEY* *       -
nw/wsj/24/wsj_2437      0       11      million CD      CD      13      nummod  _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       12      francs  NNS     NNS     10      pobj    _       -       -       -       -       *)      *       -
nw/wsj/24/wsj_2437      0       13      on      IN      IN      9       prep    _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       14      revenue NN      NN      14      pobj    _       revenue -       1       -       *       *       -
nw/wsj/24/wsj_2437      0       15      of      IN      IN      15      prep    _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       16      18.819  CD      CD      18      compound        _       -       -       -       -       (MONEY* *       -
nw/wsj/24/wsj_2437      0       17      billion CD      CD      19      nummod  _       -       -       -       -       *       *       -
nw/wsj/24/wsj_2437      0       18      francs  NNS     NNS     16      pobj    _       -       -       -       -       *)      *)      -
nw/wsj/24/wsj_2437      0       19      .       .       .       7       punct   _       -       -       -       -       *       *       -
```
