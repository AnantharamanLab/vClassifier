import argparse
from ete3 import Tree

# Create a command-line argument parser
parser = argparse.ArgumentParser(description="Identify monophyletic groups in a Newick tree.")
parser.add_argument("tree_file", help="Path to the Newick tree file")

# Parse the command-line arguments
args = parser.parse_args()

# Load the rooted midpoint tree from the specified file
tree = Tree(args.tree_file)

# Define a threshold for bootstrap values to identify monophyletic groups
bootstrap_threshold = 0.75

# Initialize an empty list to store monophyletic groups
monophyletic_groups = []

# Traverse the tree and find monophyletic groups
for node in tree.traverse():
    if node.support >= bootstrap_threshold:
        monophyletic_group = [leaf.name for leaf in node.get_leaves()]
        monophyletic_groups.append(monophyletic_group)

# Print the monophyletic groups
for i, group in enumerate(monophyletic_groups):
    print(f"Group_{i + 1}: {', '.join(group)}")

