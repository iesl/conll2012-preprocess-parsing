#!/bin/bash
#
# Converts the given field (arg2) in the given file(arg1) to BILOU format 
# from the CoNLL-2012 segment format.
#

input_file=$1
field=$2

awk -v f="$field" \
'BEGIN{curr=""; inside=0} {
  if (!NF){
    t=""
  }
  else if (NF-f-1 < 0 || $NF == $f){
    t="-"
  }
  else {
    t=$f; 
    if (t == "*"){
      if(inside){
        t="I-"curr
      } else{ 
        t="O"
      }
    }
    if (t ~ "^\\(.*" && t ~ ".*\\)$"){
      type=gensub(/\(([A-Za-z0-9-]*).*\)/, "\\1", 1, t)
      t="U-"type
    }
    else if (t ~ "^\\(.*"){
      type=gensub(/\((.*)\*/, "\\1", 1, t)
      t="B-"type
      curr=type
      inside=1
    }
    else if (t ~ ".*\\)$"){
      t=gensub(/(.*)\)/, "L-"curr, 1, t)
      inside=0
    }
    $f=t
  }
}1' $input_file | tr ' ' '\t'
