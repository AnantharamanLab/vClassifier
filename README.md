# vClassifier v1.0
### Species-level taxonomic classification of viruses

# Introduction
Leveraging reference trees and nucleotide identity metrics, we developed the vClassifier toolkit. This tool streamlines and standardizes the taxonomic categorization of prokaryotic viral genomes. Benchmark comparisons revealed that vClassifier matches or surpasses other available tools in terms of precision and classification success rates. Accurate assignments at the subfamily, genus, and species levels will significantly enhance taxonomic resolution.

Please note that this is an ALPHA version of the program, which means this collection of scripts likely contains numerous bugs and is still under development.


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


**2. add a directory to your $PATH**    
```
export PATH="/PATH/TO/vClassifier:$PATH"   #change /PATH/TO to the installation path of vClassifier
```

Please note that if you want to permanently set $PATH on Linux, add the above command to your ~/.profile or ~/.bashrc file and run:
```
source ~/.profile 
or
source ~/.bashrc
```


**3. create and activate the vClassifier conda env**
```
conda env create -f /Path/To/vClassifier.yml   #change /PATH/TO to the installation path of vClassifier 
  
conda activate vClassifier
```

# Running vClassifier

Two main programs are implemented in vClassifier: vClassifier_family and vClassifier_subfamily. In summary, vClassifier_family is used to assign taxonomy to query genomes at the family level, while vClassifier_subfamily is used to assign taxonomy at the subfamily level.

## **vClassifier_family**

**Usage:**
```
vClassifier_family -i "/PATH/TO/Input" -l "/PATH/TO/Taxa" -p "/PATH/TO/Installation" -t "Number of threads"
```
**Option descriptions:**

**-i**       Input nucleotide sequences in FASTA format

**-l**     File containing the taxa of input nucleotide sequences. The first column should contain the list of query IDs, and the second column should contain the taxon list at the family level

**-t**     Number of threads to use for parallel running

**-p**     vClassifier intallation path 

**-h**     Show help on version and usage


**Output descriptions:**

- The final output file, **"sequences_with_classification.txt"**, contains the taxonomic assignments for the query genomes. 
- The intermediate output directory, **gene_calling**,  contains files generated during gene prediction.
- The intermediate output directory, **genome_alignment**, contains files produced during the alignment of single-copy genes of queries with those of references.
- The intermediate output directory, **tree_replacement_and_taxon_assignment**, holds outputs generated during reference tree replacement and taxon assignment.


**Example:**
```
vClassifier_family -i "/PATH/TO/vClassifier/example_data/examples_of_sequences_with_family_classification/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_sequences_with_family_classification/query_family" -p "/PATH/TO/vClassifier" -t 30
```

## **vClassifier_subfamily**

**Usage:**
```
vClassifier_subfamily -i "/PATH/TO/Input" -l "/PATH/TO/Taxa" -p "/PATH/TO/Installation" -t "Number of threads"
```
**Option descriptions:**

**-i**     Input nucleotide sequences in FASTA format

**-l**     File containing the taxa of input nucleotide sequences. The first column should contain the list of query IDs, and the second column should contain the taxon list at the family level

**-t**     Number of threads to use for parallel running

**-p**     vClassifier intallation path 

**-h**     Show help on version and usage


**Output descriptions:**

- The final output file, **"sequences_with_classification.txt"**, contains the taxonomic assignments for the query genomes. 
- The intermediate output directory, **gene_calling**,  contains files generated during gene prediction.
- The intermediate output directory, **genome_alignment**, contains files produced during the alignment of single-copy genes of queries with those of references.
- The intermediate output directory, **tree_replacement_and_taxon_assignment**, holds outputs generated during reference tree replacement and taxon assignment.


**Example:**
```
vClassifier_subfamily -i "/PATH/TO/vClassifier/example_data/examples_of_sequences_with_subfamily_classification/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_sequences_with_subfamily_classification/query_subfamily" -p "/PATH/TO/vClassifier" -t 30
```
