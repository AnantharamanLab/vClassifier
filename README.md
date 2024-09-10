# vClassifier v1.0

# Introduction
Leveraging reference trees and nucleotide identity metrics, we developed the vClassifier toolkit. This tool streamlines and standardizes the taxonomic categorization of prokaryotic viral genomes. Benchmark comparisons revealed that vClassifier matches or surpasses other available tools in terms of precision and classification success rates. Accurate assignments at the subfamily, genus, and species levels will significantly enhance taxonomic resolution.

Please note that this is an ALPHA version of the program, which means this collection of scripts possiblely contains bugs and is still under development.

# Preinstallation
**Install a latest version of Miniconda**
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py312_24.7.1-0-Linux-x86_64.sh

bash Miniconda3-py312_24.7.1-0-Linux-x86_64.sh

conda activate
```

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

Two main programs are implemented in vClassifier: vClassifier for viral families and for viral subfamilies. In summary, the first one is used to assign taxonomy to viral genomes of the 36 reference families that have been listed in the /database/reference_family_list, while the second is used to assign taxonomy to viruses of the 55 reference subfamilies that have been listed in the /database/reference_family_list.

## **Quick Start**

**Usage:**
```
vClassifier -m "mode" -i "/PATH/TO/Input" -l "/PATH/TO/Taxa" -p "/PATH/TO/Installation" -t "Number of threads"
```
**Option descriptions:**

**-i**       Input nucleotide sequences in FASTA format

**-l**     A file containing family or subfamily information for the input nucleotide sequences. The first column should list the query IDs, and the second column should provide the corresponding family or subfamily taxonomy

**-t**     Number of threads to use for parallel running

**-p**     vClassifier intallation path 

**-m**     vClassifier mode. Input 'family' or 'subfamily' only. Mode 'family': inputs are viral genomes that include family information. Mode 'subfamily': inputs are viral genomes that include subfamily information

**-h**     Show help on version and usage


**Output descriptions:**

- The final output file, **"sequences_with_classification.txt"**, contains the taxonomic assignments for the query genomes. 
- The intermediate output directory, **gene_calling**,  contains files generated during gene prediction.
- The intermediate output directory, **genome_alignment**, contains files produced during the alignment of single-copy genes of queries with those of references.
- The intermediate output directory, **tree_replacement_and_taxon_assignment**, holds outputs generated during reference tree replacement and taxon assignment.


## **Testing vClassifier**
## **vClassifier for viral families**

**Example:**
```
vClassifier -m family -i "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_family_information/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_family_information/query_family" -p "/PATH/TO/vClassifier" -t 30
```

## **vClassifier_subfamily**

**Example:**
```
vClassifier -m subfamily -i "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_subfamily_information/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_subfamily_information/query_subfamily" -p "/PATH/TO/vClassifier" -t 30
```
