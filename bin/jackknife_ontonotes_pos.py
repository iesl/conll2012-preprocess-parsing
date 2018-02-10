from collections import defaultdict
import os
import argparse

arg_parser = argparse.ArgumentParser(description='Split CoNLL-2012 data into splits for jackknifing')
arg_parser.add_argument('--input_file', type=str, help='File to process')
arg_parser.add_argument('--output_dir', type=str, help='Directory to write output files')
arg_parser.add_argument('--num_splits', type=int, help='Number of splits to make')
arg_parser.set_defaults(num_splits=10)

args = arg_parser.parse_args()

if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

print('Reading in all the data and seperating by domain')
with open(args.input_file, 'r') as in_f:
    domain_sentence_map = defaultdict(list)
    current_sentence = []
    current_domain = None
    for line_num, line in enumerate(in_f):
        line = line.strip()
        # blank line means end of sentence
        if not line:
            sentence_str = '\n'.join(current_sentence)
            domain_sentence_map[current_domain].append(sentence_str)
            current_sentence = []
        else:
            current_sentence.append(line)
            current_domain = line.split('/', 1)[0]

# write num_splits train and test files
train_files = [open('%s/train_%d' % (args.output_dir, i), 'w') for i in range(args.num_splits)]
test_files = [open('%s/test_%d' % (args.output_dir, i), 'w') for i in range(args.num_splits)]
for split_num in range(args.num_splits):
    print('writing split: %d' % split_num)
    for domain, sentences in domain_sentence_map.iteritems():
        for sent_num, sentence in enumerate(sentences):
            if sent_num % 10 == split_num:
                test_files[split_num].write('%s\n\n' % sentence)
            else:
                train_files[split_num].write('%s\n\n' % sentence)
print('Done')
