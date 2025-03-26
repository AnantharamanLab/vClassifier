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

Create env via conda:
```
conda env create -f /Path/To/vClassifier.yml   #change /PATH/TO to the installation path of vClassifier 
conda activate vClassifier
```

Alternatively, create env via mamba to accelerate installation:
```
conda install mamba -c conda-forge
mamba env create -f /Path/To/vClassifier.yml   #change /PATH/TO to the installation path of vClassifier 
conda activate vClassifier
```

If you encounter the following errors during installation:
```
LibMambaUnsatisfiableError: Encountered problems while solving:
  - package perl-extutils-makemaker-7.70-pl5321hd8ed1ab_0 is excluded by strict repo priority
  - package perl-file-path-2.18-pl5321hd8ed1ab_0 is excluded by strict repo priority
  - package perl-file-temp-0.2304-pl5321hd8ed1ab_0 is excluded by strict repo priority
  - package perl-file-which-1.24-pl5321hd8ed1ab_0 is excluded by strict repo priority
```
​Please enter the following command to set the channel priority to flexible:
```
conda config --set channel_priority flexible
```
Afterward, rerun the command:
```
conda env create -f /Path/To/vClassifier.yml  #change /PATH/TO to the installation path of vClassifier
conda activate vClassifier
```
Or
```
mamba env create -f /Path/To/vClassifier.yml   #change /PATH/TO to the installation path of vClassifier 
conda activate vClassifier
```


# Running vClassifier

Two main programs are implemented in vClassifier: vClassifier for viral families and for viral subfamilies. In summary, the first one is used to assign taxonomy to viral genomes of the 36 reference families that have been listed in the `/database/reference_family_list`, while the second is used to assign taxonomy to viruses of the 55 reference subfamilies that have been listed in the `/database/reference_family_list`.

## **Quick Start**

### **Usage:**
```
vClassifier -m "mode" -i "/PATH/TO/Input" -l "/PATH/TO/Taxa" -p "/Full/PATH/TO/Installation" -o "Output directory" -t "Number of threads"
```
### **Option descriptions:**

**-i**     Input nucleotide sequences in FASTA format. Please note that providing the full path is recommend to avoid errors.

**-l**     A file containing family or subfamily information for the input nucleotide sequences. The first column should list the query IDs, and the second column should provide the corresponding family or subfamily taxonomy. Please note that providing the full path is recommended to avoid errors.

**-t**     Number of threads to use for parallel running.

**-p**     Full installation path for vClassifier. Please verify that the directories for the database and scripts are present under this path.

**-m**     vClassifier mode. Input 'family' or 'subfamily' only. Mode 'family': inputs are viral genomes that include family information. Mode 'subfamily': inputs are viral genomes that include subfamily information.

**-o**     Output directory.

**-h**     Show help on version and usage.


### **Output descriptions:**

The vClassifier output folder will have this structure:

```
vClassifier_output
├── final_taxonomic_assignment.txt
├── gene_calling
├── genome_alignment
└── tree_replacement_and_taxon_assignment
```

**`final_taxonomic_assignment.txt`:**

Contains the taxonomic assignments for the query genomes, it should look like this (using the vClassifier family example data):

```
Query           Species                 Genus           Subfamily               Family          Order           Class             Phylum             Kingdom         Realm
AJ604531.1      Tequintavirus NBSal003  Tequintavirus   Markadamsvirinae        Demerecviridae  NA              Caudoviricetes    Uroviricota        Heunggongvirae  Duplodnaviria
AB218927.1      Emesvirus japonicum     Emesvirus       NA                      Fiersviridae    Norzivirales    Leviviricetes     Lenarviricota      Orthornavirae   Riboviria
CP013282.1      Betatectivirus Bam35    Betatectivirus  NA                      Tectiviridae    Kalamavirales   Tectiliviricetes  Preplasmiviricota  Bamfordvirae    Varidnaviria
AY846870.1      Gruunavirus GTE5        Gruunavirus     Emilbogenvirinae        Zierdtviridae   NA              Caudoviricetes    Uroviricota        Heunggongvirae  Duplodnaviria
```

Any query genome that vClassifier was able to classify below the family level (for family mode) or the subfamily level (for subfamily mode) will be listed here.

Ranks without an assignment will be listed as "Unassigned", such as in this example using virus sequences identified from a soil metagenome using geNomad:

```
Query                   Species         Genus           Subfamily       Family          Order   Class           Phylum          Kingdom         Realm
BAr1A1B1C_000000194000  Unassigned      NA              Tevenvirinae    Straboviridae   NA      Caudoviricetes  Uroviricota     Heunggongvirae  Duplodnaviria
BAr1A1B1C_000000025753  Unassigned      Ishigurovirus   Emmerichvirinae Straboviridae   NA      Caudoviricetes  Uroviricota     Heunggongvirae  Duplodnaviria
BAr1A1B1C_000000314370  Unassigned      Sauletekiovirus NA              Drexlerviridae  NA      Caudoviricetes  Uroviricota     Heunggongvirae  Duplodnaviria
BAr1A1B1C_000000343757  Unassigned      Lazarusvirus    Twarogvirinae   Straboviridae   NA      Caudoviricetes  Uroviricota     Heunggongvirae  Duplodnaviria
```

Fields with "NA" means that there are currently no ICTV-recognized taxa for that rank in the listed virus lineage (this is common at the Order-level).


**`gene_calling`:**

An intermediate output directory containing files generated during gene prediction


**`genome_alignment`:**

An intermediate output directory containing files produced during the alignment of single-copy genes of queries with those of references


**`tree_replacement_and_taxon_assignment`:**

An intermediate output directory containing file generated during reference tree replacement and taxon assignment.


## **Testing vClassifier**
### **vClassifier for viral families**

**Example:**
```
vClassifier -m family -i "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_family_information/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_family_information/query_family" -p "/Full/PATH/TO/vClassifier" -o Output_dir -t 30
```

### **vClassifier for viral subfamilies**

**Example:**
```
vClassifier -m subfamily -i "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_subfamily_information/query_genomes.fna" -l "/PATH/TO/vClassifier/example_data/examples_of_viral_genomes_that_include_subfamily_information/query_subfamily" -p "/Full/PATH/TO/vClassifier" -o Output_dir -t 30
```


# Troubleshooting tips
## Setting up the conda environment is taking too long
If you run the `conda env create -f /Path/To/vClassifier.yml` command and you find that it has been stuck on the `Solving environment` stage for >30 minutes, you can speed up installation using [mamba](https://github.com/mamba-org/mamba). To do this, follow the steps below:
1. Activate your base conda environment (if it isn't already activated) by running `conda activate`
2. Install mamba following the instructions in [the mamba documentation](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html), or by running `conda install conda-forge::mamba` (the latter is not recommended by the mamba documentation but it should work in most cases)
3. Set up the vClassifier environment using mamba with `mamba env create -f /Path/To/vClassifier.yml` (again, ensuring that you change `/Path/To/vClassifier.yml` to your actual location of the `vClassifier.yml` file)

## How can I obtain the family/subfamily information file required by the `-l` argument?
In theory, if you know the [ICTV taxonomy](https://ictv.global/taxonomy) at the family or subfamily level for all of your input viral sequences, you can create this two-column (tab separated) file yourself by listing the viral sequence names present in your query fasta file in the first column, the corresponding family or subfamily taxonomy in the second column.

But in practice, you may not have this information already. **We recommend obtaining family and subfamily taxonomic assignments from [geNomad](https://github.com/apcamargo/genomad)**. Note that geNomad versions 1.11.0 and higher can provide classifications to the family as well as subfamily level with either the `--full-ictv-lineage` or `--lenient-taxonomy` options.

If you use geNomad to identify the viruses in your query fasta file, this information should be present in the **taxonomy** column of either files ending in `_taxonomy.tsv` or `_virus_summary.tsv` (present in the `genomad annotate` and `genomad summary` output folders). For convienence, **we have provided an auxiliary script `extract_genomad_taxonomy.py` that will automatically make the required taxonomy file** by searching for the suffixes *-idae* and *-inae*, which should be at the end of all ICTV family and subfamily names, respectively. If you can provide the path to either the geNomad `taxonomy.tsv` or `virus_summary.tsv` files and your query FASTA file:

For extracting family-level information:
```
python3 /PATH/TO/vClassifier/scripts/extract_genomad_taxonomy.py family <path to query FASTA> <path to genomad summary/taxonomy table> <output filename>
```

For extracting sumfaily-level information:
```
python3 /PATH/TO/vClassifier/scripts/extract_genomad_taxonomy.py subfamily <path to query FASTA> <path to genomad summary/taxonomy table> <output filename>
```

There are other tools that you may use to obtain family- or subfamily- level taxonomic assignments for your query virus sequences, but the `extract_genomad_taxonomy.py` script is only compatible with tab-separated tables that contain the sequences names in a column named `seq_name` and taxnomic assignments in a column named `taxnomy` or `lineage`, with rank names separated by `;` (i.e. the geNomad summary or taxonomy files).

If the output file is empty, see the next section below.

## What if I cannot obtain family- or subfamily-level taxonomic assignments before running vClassifier?
If you are unable to obtain this information using geNomad, other tools, or using taxonomy of references sequences, please consider the following:
- If the output file from `extract_genomad_taxonomy.py` is empty, then that means there were no available family/subfamily taxonomic assignments from the geNomad taxonomy table for any of the query sequences. If this happens, then vClassifier will not be able to classify your sequences. You might try an alternative tool or method to provide family/subfamily assignments, but you will need to create the family/subfamily information file yourself.
- You should inspect the geNomad taxonomy file or whatever source you used to obtain the query viruses. It is not uncommon for there to be no assignment below the class level (e.g. Caudoviricetes) for complex and understudied environments, or for previously undescribed virus lineages. In this case, you could try using more lenient family assignment methods, but the downstream results should be interpreted with caution.
  - If this still doesn't work and you are confident that your query sequences are truly viral yet highly novel (i.e. possibly representative of an undescribed virus class or higher) then vClassifier or similar tools are not likely the best option to classify the sequences.
- Your query sequences may be of overall poor quality (i.e. too short to obtain any taxonomic information or likely not a viral sequence at all). If you used a virus identification tool like geNomad or others to identify viral sequences from genomes and metagenomes, check their corresponding scores or confidence assignments.
