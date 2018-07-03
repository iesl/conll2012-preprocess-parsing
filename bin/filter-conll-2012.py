from __future__ import print_function
import argparse
import gzip
import os
from glob import glob

arg_parser = argparse.ArgumentParser(description='Filter CoNLL-12 files by docid and concatenate')
arg_parser.add_argument('--input_dir', type=str, help='Directory to process')
arg_parser.add_argument('--docid_file', type=str, default='', help='List of doc ids to keep')
args = arg_parser.parse_args()

docid_map = set()

if args.docid_file != '':
  with open(args.docid_file, 'r') as f:
    for line in f:
      line = line.strip()
      docid_map.add(line)

fnames = [d for f in os.walk(args.input_dir) for d in glob(os.path.join(f[0], '*.combined'))]

for fname in fnames:
  with open(fname, 'r') as f:
    last_print_empty = True
    for line in f:
      line = line.strip()
      if line:
        split_line = line.strip().split()
        docid = split_line[0].split('/')[-1]
        if docid in docid_map or not docid_map:
          print(line)
          last_print_empty = False
      else:
        if not last_print_empty:
          print()
        last_print_empty = True
