from __future__ import print_function
import argparse
import gzip

arg_parser = argparse.ArgumentParser(description='Convert a CoNLL-2012 file to CoNLL-X format')
arg_parser.add_argument('--input_file', type=str, help='File to process')
arg_parser.add_argument('--docid_file', type=str, help='List of doc ids to keep')
args = arg_parser.parse_args()

docid_map = {}
with open(args.docid_file, 'r') as f:
  for line in f:
    line = line.strip()
    docid_map += line

print(docid_map)

with open(args.input_file, 'r') as f:
  for line in f:
    line = line.strip()
    if line:
      split_line = line.strip().split()
      docid = split_line[0].split('/')[-1]
      if docid in docid_map:
        print(line)
    else:
      print()
