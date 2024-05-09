V-Classifier v1.0

Introduction
Leveraging reference trees and nucleotide identity metrics, we developed the V-Classifier toolkit. This tool streamlines and objectifies the taxonomic categorization of prokaryotic viral genomes. Benchmark comparisons revealed that V-Classifier matches or surpasses other available tools regarding precision and classification success rates. Accurate assignments at the subfamily, genus, and species levels will significantly refine taxonomic resolution.

Note that this is an ALPHA version of the program, meaning that this collection of scripts likely contains a lot of bugs, and it is still under development.


How to install V-Classifier
1.copy to your profile the content of the V-Classifier folder
  git clone https://github.com/AnantharamanLab/V-Classifier.git

2.create and activate the V-Classifier conda env
  conda env create -f V-Classifier.yml
  conda activate V-Classifier

3.export PATH="/PATH/TO/V-Classifier:$PATH"    #change /PATH/TO the installation path of V-Classifier

Running V-Classifier
Two main programs are implemented in GRAViTy: V-Classifier-family and V-Classifier-subfamily. In summary, V-Classifier-family is used to assign taxonomy to query genomes with taxonomic information at family level, and V-Classifier-subfamily is used to assign taxonomy to query genomes with taxonomic information at subfamily level.

V-Classifier-family
Usage
V-Classifier-family -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/taxa_of_query_genomes.txt" -p "/PATH/TO/Installation" -t "Number of threads"

Option descriptions
-i     Input query genomes in FASTA format.
-l     Input taxon list of query genomes. First column is the list of query ID and second is the taxon list at family level.
-t     Number of threads to use for parallel running.
-p     Path of intallation of V-Classifier.
-h     Show help on version and usage.

Output descriptions
Final output file is the "sequences_with_classification.txt" that is the taxonomic assignment to query genomes.
Intermediate outputs are mainly organised into three directories.
- gene_calling directory contains files generated during gene prediction.
- genome_alignment directory contains files generated during alignment of single-copy genes of queries with that of references.
- tree_replacement_and_taxon_assignment directory contains outputs generated during reference tree replacement and taxon assignment.

EXAMPLE
V-Classifier-family -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/query_family" -p "/PATH/TO/V-Classifier" -t 30


V-Classifier-subfamily
Usage
V-Classifier-subfamily -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/taxa_of_query_genomes.txt" -p "/PATH/TO/Installation" -t "Number of threads"

Option descriptions
-i     Input query genomes in FASTA format.
-l     Input taxon list of query genomes. First column is the list of query ID and second is the taxon list at subfamily level.
-t     Number of threads to use for parallel running.
-p     Path of intallation of V-Classifier.
-h     Show help on version and usage.

Output descriptions
Final output file is the "sequences_with_classification.txt" that is the taxonomic assignment to query genomes.
Intermediate outputs are mainly organised into three directories.
- gene_calling directory contains files generated during gene prediction.
- genome_alignment directory contains files generated during alignment of single-copy genes of queries with that of references.
- tree_replacement_and_taxon_assignment directory contains outputs generated during reference tree replacement and taxon assignment.

EXAMPLE
V-Classifier-subfamily -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/query_subfamily" -p "/PATH/TO/V-Classifier" -t 30

