#!/bin/bash
#
# Grab all the jars needed for running ClearNLP POS tagger, constituencies -> dependencies conversion
# As of 12/19/2017
#

mkdir lib
cd lib

# ClearNLP
curl -LO "http://search.maven.org/remotecontent?filepath=edu/emory/clir/clearnlp/3.1.2/clearnlp-3.1.2.jar"

# ClearNLP dependencies
curl -LO "http://search.maven.org/remotecontent?filepath=args4j/args4j/2.0.29/args4j-2.0.29.jar"
curl -LO "http://search.maven.org/remotecontent?filepath=log4j/log4j/1.2.17/log4j-1.2.17.jar"
curl -LO "http://search.maven.org/remotecontent?filepath=com/carrotsearch/hppc/0.6.1/hppc-0.6.1.jar"
curl -LO "http://search.maven.org/remotecontent?filepath=org/tukaani/xz/1.5/xz-1.5.jar"

# Dictionaries, needed for converting constituencies -> dependencies
curl -LO "http://search.maven.org/remotecontent?filepath=edu/emory/clir/clearnlp-dictionary/3.2/clearnlp-dictionary-3.2.jar"

# POS tagger model
curl -LO "http://search.maven.org/remotecontent?filepath=edu/emory/clir/clearnlp-general-en-pos/3.2/clearnlp-general-en-pos-3.2.jar"

# word clusters
curl -LO "http://search.maven.org/remotecontent?filepath=edu/emory/clir/clearnlp-global-lexica/3.1/clearnlp-global-lexica-3.1.jar"

cd ..
