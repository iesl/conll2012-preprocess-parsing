from __future__ import print_function
import argparse

arg_parser = argparse.ArgumentParser(description='Add sent ids to CoNLL-2012 file')
arg_parser.add_argument('--input_file', type=str, help='File to process')

args = arg_parser.parse_args()

with open(args.input_file, 'r') as in_f:
    current_doc = ''
    sent_num = 0
    for line_num, line in enumerate(in_f):
        line = line.strip()
        # blank line means end of sentence
        if not line:
            sent_num += 1
            print()
        else:
            split_line = line.split('\t')
            this_doc = split_line[0]
            if this_doc != current_doc:
                currect_doc = this_doc
                sent_num = 0
            split_line[1] = str(sent_num)
            print('\t'.join(split_line))

