#!/usr/bin/env python3
import sys

def print_help():
    help_message = f"""Usage: {sys.argv[0]} <family|subfamily> <fasta file> <taxonomy.tsv> <output file>
    
This script extracts family or subfamily assignments from a taxonomy TSV file, matching sequence names
against a provided FASTA file. The taxonomy column (named either "taxonomy" or "lineage") is split by
semicolons, and the most specific classification ending with:
  - "idae" is selected for family mode,
  - "inae" is selected for subfamily mode.

Arguments:
  <family|subfamily>  Mode: 'family' to extract family names (ending in 'idae') or 
                      'subfamily' to extract subfamily names (ending in 'inae').
  <fasta file>        Path to the FASTA file. Only sequences present in this file are processed.
  <taxonomy.tsv>      Path to the taxonomy TSV file (with a header line containing 'seq_name' and either
                      'taxonomy' or 'lineage' columns).
  <output file>       Path to the output file (tab-separated file with seq_name and assigned taxonomy).

Options:
  -h, --help          Show this help message and exit.
"""
    sys.stdout.write(help_message)
    sys.exit(0)

def main():
    # Check for help option anywhere in the arguments
    if any(arg in ("-h", "--help") for arg in sys.argv):
        print_help()
    
    # Expect exactly 5 arguments: script, mode, fasta, taxonomy, output
    if len(sys.argv) != 5:
        sys.stderr.write(f"Usage: {sys.argv[0]} <family|subfamily> <fasta file> <taxonomy.tsv> <output file>\n")
        sys.exit(1)
    
    mode = sys.argv[1]
    if mode not in ("family", "subfamily"):
        sys.stderr.write("Error: First argument must be either 'family' or 'subfamily'.\n")
        sys.exit(1)
    
    # Positional argument order: fasta file, taxonomy file, output file
    fasta_file = sys.argv[2]
    taxonomy_file = sys.argv[3]
    output_file = sys.argv[4]
    
    total_sequences_table = 0
    assignments_found = 0
    
    # Suffix to search for based on mode.
    suffix = "idae" if mode == "family" else "inae"
    
    # Read the FASTA file and store sequence names in a set
    fasta_sequences = set()
    try:
        with open(fasta_file, "r") as f:
            for line in f:
                line = line.strip()
                # Only process header lines
                if line.startswith(">"):
                    # Remove the '>' and take the first token (up to whitespace) as sequence name
                    seq_name = line[1:].split()[0]
                    fasta_sequences.add(seq_name)
    except FileNotFoundError as e:
        sys.stderr.write(f"FASTA file not found: {e}\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"An error occurred reading the FASTA file: {e}\n")
        sys.exit(1)
    
    fasta_count = len(fasta_sequences)
    
    try:
        with open(taxonomy_file, "r") as infile, open(output_file, "w") as outfile:
            # Read header line and determine column indices
            header_line = infile.readline().strip()
            if not header_line:
                sys.stderr.write("Error: Taxonomy file is empty or missing a header line.\n")
                sys.exit(1)
            
            header_cols = header_line.split("\t")
            seq_col_index = None
            tax_col_index = None
            
            for i, col in enumerate(header_cols):
                col_lower = col.strip().lower()
                if col_lower == "seq_name":
                    seq_col_index = i
                elif col_lower in ("taxonomy", "lineage"):
                    tax_col_index = i
            
            if seq_col_index is None or tax_col_index is None:
                sys.stderr.write(
                    f"Error: Taxonomy table must have 'seq_name' and either 'taxonomy' or 'lineage' column headers.\nHeader columns:\n{header_line}\n"
                )
                sys.exit(1)
            
            # Process each subsequent line
            for line in infile:
                line = line.strip()
                if not line:
                    continue # Skip empty lines
                total_sequences_table += 1
                
                fields = line.split("\t")
                # Ensure there are enough columns
                if len(fields) <= max(seq_col_index, tax_col_index):
                    continue
                
                seq_name = fields[seq_col_index]
                taxonomy = fields[tax_col_index]
                
                # # If '|provirus' is present in the sequence name, keep only the part before it
                # if "|provirus" in seq_name:
                #     seq_name = seq_name.split("|provirus", 1)[0]
                
                # Only process sequences that are present in the FASTA file
                if seq_name not in fasta_sequences:
                    continue
                
                # Split the taxonomy field on semicolon
                tax_parts = taxonomy.split(";")
                
                # Iterate in reverse to find the most specific classification ending with the expected suffix
                candidate = None
                for taxon in reversed(tax_parts):
                    taxon = taxon.strip()
                    if taxon.endswith(suffix):
                        candidate = taxon
                        break
                
                # If no matching taxonomy was found, skip this sequence
                if candidate is None:
                    continue
                
                # Write the output (seq_name and candidate assignment separated by a tab, no header).
                outfile.write(f"{seq_name}\t{candidate}\n")
                assignments_found += 1
    
    except FileNotFoundError as e:
        sys.stderr.write(f"Taxonomy file not found: {e}\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"An error occurred processing the taxonomy file: {e}\n")
        sys.exit(1)
    
    sys.stdout.write(
        f"Done processing.\nTotal sequences in the taxonomy table: {total_sequences_table}\n"
        f"Total sequences in the FASTA file: {fasta_count}\n"
        f"Total {mode} assignments found: {assignments_found}\n"
    )

if __name__ == "__main__":
    main()
