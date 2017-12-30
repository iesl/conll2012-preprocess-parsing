from __future__ import print_function
import argparse

arg_parser = argparse.ArgumentParser(description='Convert a field in CoNLL-2012 to BIO/BILOU format')
arg_parser.add_argument('--input_file', type=str, help='File to process')
arg_parser.add_argument('--field', type=int, help='Field in the file to process')
arg_parser.add_argument('--bilou', type=bool, help='Whether to use BILOU encoding (BIO otherwise)', default=False)

args = arg_parser.parse_args()

join_str = '/'
with open(args.input_file, 'r') as f:
  label_stack = []
  for line_num, line in enumerate(f):
    split_line = line.strip().split()
    if not split_line:
      assert not label_stack, "There remains an unclosed paren (line %d) labels: %s" % (line_num, ','.join(label_stack))
    elif args.field < len(split_line)-1:
      field = split_line[args.field]
      output_labels = map(lambda s: "I-" + s, label_stack)
      if field == "*" and not label_stack:
        output_labels.append("O")
      else:
        split_field = field.split("(")
        for label in split_field:
          if label:
            if label[0] == "*":
              close_parens = label.count(")")
              close_labels = ["L-" + label_stack.pop(-1) for i in range(close_parens)]
              if args.bilou:
                output_labels = output_labels[:len(output_labels)-close_parens] + close_labels
            else:
              if label[-1] == ")":
                if args.bilou:
                  output_labels.append("U-" + label.strip("*)"))
                else:
                  output_labels.append("B-" + label.strip("*)"))
              else:
                label = label.strip("*)")
                label_stack.append(label)
                output_labels.append("B-" + label)
      new_label = join_str.join(output_labels)
      split_line[args.field] = new_label
    print('\t'.join(split_line))



