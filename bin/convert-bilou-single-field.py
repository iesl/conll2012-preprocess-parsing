from __future__ import print_function
import argparse

arg_parser = argparse.ArgumentParser(description='Convert a field in CoNLL-2012 to BIO/BILOU format')
arg_parser.add_argument('--input_file', type=str, help='File to process')
arg_parser.add_argument('--field', type=int, help='Field in the file to process')
arg_parser.add_argument('--bilou', dest='bilou', help='Whether to use BILOU encoding (default BIO)', default=False, action='store_true')
arg_parser.add_argument('--bio', dest='bilou', help='Whether to use BIO encoding (default)', default=False, action='store_false')


args = arg_parser.parse_args()

join_str = '/'
# (R-ARG1*))
# (ARG1(ARG0*)) --> U-ARG1/U-ARG0 (U-ARG0/L-ARG1)
with open(args.input_file, 'r') as f:
  label_stack = []
  for line_num, line in enumerate(f):
    new_labels = []
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
        # gather new labels introduced
        for label in split_field:
          stripped = label.strip("()*")
          if stripped:
            new_labels.append(stripped)

        # do we close labels?
        close_parens = field.count(")")
        unit_labels = []
        close_labels = []
        if close_parens > 0:
          # if there are new labels, close those first
          while new_labels and close_parens > 0:
            if args.bilou:
              unit_label = "U-" + new_labels.pop()
            else:
              unit_label = "B-" + new_labels.pop()
            close_parens -= 1
            unit_labels.append(unit_label)

          # if there are additional close parens, close labels from label stack
          if args.bilou:
            close_labels = ["L-" + label_stack.pop(-1) for i in range(close_parens)]
          else:
            close_labels = ["I-" + label_stack.pop(-1) for i in range(close_parens)]

        # add unclosed new labels to label stack, and begin them
        start_labels = []
        while new_labels:
          new_label = new_labels.pop()
          start_labels.append("B-" + new_label)
          label_stack.append(new_label)

        output_labels = output_labels[:len(output_labels) - close_parens] + start_labels + unit_labels + close_labels


      new_label = join_str.join(output_labels)
      split_line[args.field] = new_label
    print('\t'.join(split_line))

# with open(args.input_file, 'r') as f:
#   label_stack = []
#   for line_num, line in enumerate(f):
#     split_line = line.strip().split()
#     if not split_line:
#       assert not label_stack, "There remains an unclosed paren (line %d) labels: %s" % (line_num, ','.join(label_stack))
#     elif args.field < len(split_line)-1:
#       field = split_line[args.field]
#       output_labels = map(lambda s: "I-" + s, label_stack)
#       if field == "*" and not label_stack:
#         output_labels.append("O")
#       else:
#         split_field = field.split("(")
#         for label in split_field:
#           if label:
#             if label[0] == "*":
#               close_parens = label.count(")")
#               close_labels = ["L-" + label_stack.pop(-1) for i in range(close_parens)]
#               if args.bilou:
#                 output_labels = output_labels[:len(output_labels)-close_parens] + close_labels
#             else:
#               close_parens = label.count(")")
#               if close_parens > 0:
#               # if label[-1] == ")":
#                 if args.bilou:
#                   unit_label = "U-" + label.strip("*)")
#                   close_labels = ["L-" + label_stack.pop(-1) for i in range(close_parens - 1)]
#                 else:
#                   unit_label = "B-" + label.strip("*)")
#                   close_labels = ["I-" + label_stack.pop(-1) for i in range(close_parens - 1)]
#                 output_labels = output_labels[:len(output_labels) - (close_parens-1)] + [unit_label] + close_labels
#               else:
#                 label = label.strip("*")
#                 label_stack.append(label)
#                 output_labels.append("B-" + label)
#       new_label = join_str.join(output_labels)
#       split_line[args.field] = new_label
#     print('\t'.join(split_line))



