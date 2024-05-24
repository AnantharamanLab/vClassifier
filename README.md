# vClassifier v1.0

# Introduction
Leveraging reference trees and nucleotide identity metrics, we developed the vClassifier toolkit. This tool streamlines and objectifies the taxonomic categorization of prokaryotic viral genomes. Benchmark comparisons revealed that vClassifier matches or surpasses other available tools regarding precision and classification success rates. Accurate assignments at the subfamily, genus, and species levels will significantly refine taxonomic resolution.

Note that this is an ALPHA version of the program, meaning that this collection of scripts likely contains a lot of bugs, and it is still under development.


# How to install vClassifier

**1. copy to your profile the content of the vClassifier folder**
```
  git clone https://github.com/AnantharamanLab/vClassifier.git
  
  cd vClassifier/database
  
  unzip packages_for_pplacer.zip
  
  unzip VOG_protein_sequences_at_FamilyOrSubfamily_rank.zip
  
  gzip -d reference_genomes.fasta.gz
  
  wget https://fileshare.lisc.univie.ac.at/vog/vog216/vog.hmm.tar.gz
  
  mkdir VOG_hmmfiles
  
  cd VOG_hmmfiles && tar -zxf ../vog.hmm.tar.gz && cd -
```  

**2. create and activate the vClassifier conda env**
```
  conda env create -f vClassifier.yml
  
  conda activate vClassifier
```  

**3. Add a directory to your PATH**    
```
export PATH="/PATH/TO/vClassifier:$PATH"  #change /PATH/TO to the installation path of vClassifier 
```
# Running vClassifier

Two main programs are implemented in GRAViTy: vClassifier_family and vClassifier_subfamily. In summary, vClassifier_family is used to assign taxonomy to query genomes with taxonomic information at family level, and vClassifier_subfamily is used to assign taxonomy to query genomes with taxonomic information at subfamily level.

## **vClassifier_family**

**Usage:**
```
vClassifier_family -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/taxa_of_query_genomes.txt" -p "/PATH/TO/Installation" -t "Number of threads"
```
**Option descriptions:**

-i     Input query genomes in FASTA format.

-l     Input taxon list of query genomes. First column is the list of query ID and second is the taxon list at family level.

-t     Number of threads to use for parallel running.

-p     Path of intallation of vClassifier.

-h     Show help on version and usage.


**Output descriptions:**

Final output file is the "sequences_with_classification.txt" that is the taxonomic assignment to query genomes.
Intermediate outputs are mainly organised into three directories.

- directory **gene_calling** contains files generated during gene prediction.
- directory **genome_alignment** contains files generated during alignment of single-copy genes of queries with that of references.
- directory **tree_replacement_and_taxon_assignment** contains outputs generated during reference tree replacement and taxon assignment.

**Example:**
```
vClassifier_family -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/query_family" -p "/PATH/TO/vClassifier" -t 30
```

## **vClassifier_subfamily**

**Usage:**
```
vClassifier_subfamily -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/taxa_of_query_genomes.txt" -p "/PATH/TO/Installation" -t "Number of threads"
```
**Option descriptions:**

-i     Input query genomes in FASTA format.

-l     Input taxon list of query genomes. First column is the list of query ID and second is the taxon list at subfamily level.

-t     Number of threads to use for parallel running.

-p     Path of intallation of vClassifier.

-h     Show help on version and usage.


**Output descriptions:**

Final output file is the "sequences_with_classification.txt" that is the taxonomic assignment to query genomes.
Intermediate outputs are mainly organised into three directories.

- directory **gene_calling** contains files generated during gene prediction.
- directory **genome_alignment** contains files generated during alignment of single-copy genes of queries with that of references.
- directory **tree_replacement_and_taxon_assignment** contains outputs generated during reference tree replacement and taxon assignment.


**Example:**
```
vClassifier_subfamily -i "/PATH/TO/query_genomes.fna" -l "/PATH/TO/query_subfamily" -p "/PATH/TO/vClassifier" -t 30
```
