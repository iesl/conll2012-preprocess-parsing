# conll2012-preprocess-parsing
Scripts for pre-processing the CoNLL-2012 dataset for syntactic dependency parsing.

These scripts attempt to replicate the pre-processing of the [CoNLL-2012 subset](http://conll.cemantix.org/2012/data.html) of the OntoNotes corpus described in the paper 
[It Depends: Dependency Parser Comparison Using A Web-based Evaluation Tool](http://www.aclweb.org/anthology/P/P15/P15-1038.pdf).

Specifically, they use [ClearNLP](https://github.com/clir/clearnlp) to (1) convert the
constituency parses to dependency structure (w/ head rules [described here](http://www.mathcs.emory.edu/~choi/doc/cu-2012-choi.pdf) 
and (2) assign automatic part-of-speech tags.

The scripts assume you have already extracted the CoNLL-2012 split from the OntoNotes corpus, [as described here](http://conll.cemantix.org/2012/data.html).

Note that these scripts *do not* remove length-1 sentences, as was done in the paper cited above. We leave you to do that if you choose.

Do the pre-processing
--------------
```
./preprocess_conll2012.sh ~/canvas/data/conll-2012/dev
./preprocess_conll2012.sh ~/canvas/data/conll-2012/test
./preprocess_conll2012.sh ~/canvas/data/conll-2012/train
```

Combine into single files
--------------
```
for f in `find $HOME/canvas/data/conll-2012/train -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-train.txt; done
for f in `find $HOME/canvas/data/conll-2012/dev -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-dev.txt; done
for f in `find $HOME/canvas/data/conll-2012/test -type f -name "*\.parse\.dep\.combined"`; do cat $f >> conll2012-test.txt; done
```
