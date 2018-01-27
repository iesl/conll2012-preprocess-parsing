from __future__ import print_function
import argparse

arg_parser = argparse.ArgumentParser(description='Convert a CoNLL-2012 file to CoNLL-2005 prop format')
arg_parser.add_argument('--input_file', type=str, help='File to process')
arg_parser.add_argument('--word_field', type=int, help='Field containing words')
arg_parser.add_argument('--pred_field', type=int, help='Field containing predicates')
arg_parser.add_argument('--first_prop_field', type=int, help='First field containing props')

args = arg_parser.parse_args()

with open(args.input_file, 'r') as f:
  for line in f:
    line = line.strip()
    if line:
      split_line = line.strip().split('\t')
      props = split_line[args.first_prop_field:-1]
      word = split_line[args.word_field] if split_line[args.pred_field + 1] != '-' else '-'
      new_fields = [word] + props
      new_line = '\t'.join(new_fields)
      print(new_line)
    else:
      print()
