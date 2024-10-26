#! /bin/bash
################################################################################
################################################################################
################################################################################
#                                                                              #
#  Copyright (C) 2024 Kun Zhou                                                 #
#  zkccnu@gmail.com                                                            #
#                                                                              #
#  This program is free software; you can redistribute it and/or modify        #
#  it under the terms of the GNU General Public License as published by        #
#  the Free Software Foundation; either version 2 of the License, or           #
#  (at your option) any later version.                                         #
#                                                                              #
#  This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
#  GNU General Public License for more details.                                #
#                                                                              #
#                                                                              #
################################################################################
################################################################################
################################################################################

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   echo "vClassifier v1.0 :: classification of viral genomes based on phylogeny and genome identity"
   echo 
   echo "Usage: vClassifier_subfamily [-i|-l|-t|-p|-h]"
   echo "options:"
   echo "-i     Input nucleotide sequences in FASTA format."
   echo "-l     A file containing family or subfamily information for the input nucleotide sequences. The first column should listthe query IDs, and the second column should provide the corresponding subfamily taxonomy."
   echo "-t     Number of threads to use for parallel running."
   echo "-p     vClassifier intallation path."
   echo "-h     Show help on version and usage."
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################
################################################################################
# Process the input options. Add options as needed.                            #
################################################################################
# Get the options

while getopts :hl:t:i:p: option
do
    case "${option}" in
        i) query_genome=${OPTARG};;
        l) query_taxonomy=${OPTARG};;
        t) threads=${OPTARG};;
	p) installer_dir=${OPTARG};;
	h) Help
	   exit;;
	\?) echo "Error: Invalid option."
	   exit;;
    esac
done

echo ====================================================================================================

##Step 1: Gene calling and VOG annotation
echo $(date)"	Step 1: Gene calling and VOG annotation"

VOG_database="$installer_dir/database/VOG_hmmfiles"
scripts="$installer_dir/scripts"
wd=`pwd`

mkdir gene_calling
cp $query_genome gene_calling
cd gene_calling

########## Output two files: one is queries.num, another is queries.raw that contains original seq ID.
perl $scripts/sequenceID_modification.pl $query_genome queries

awk 'BEGIN {n=0;} /^>/ {if(n%1000==0){file=sprintf("chunk%d.fa",n);} print >> file; n++; next;} { print >> file; }' < queries.num

for i in chunk*.fa
do
    echo "prodigal -a $i.protein.faa -i $i -m  -p meta -q -o $i.gff"
done > prodigal_batch.sh

perl $scripts/multiple_threads.pl prodigal_batch.sh -c $threads
cat chunk*fa.protein.faa > queries.protein.faa
rm chunk*.fa chunk*fa.protein.faa chunk*gff
cd $VOG_database

for i in *hmm
do
    echo "hmmsearch -o /dev/null --domtblout "$i".hmmout -E 1e-3 --cpu 0 $VOG_database/$i $wd/gene_calling/queries.protein.faa"
done > $wd/hmmsearch_batch.sh

cd $wd
perl $scripts/multiple_threads.pl hmmsearch_batch.sh -c $threads
cat *.hmmout|grep -v '^#' | awk ' ($3 != 0 && $6 != 0 && ($17-$16)/$6) > 0.5 && (($19-$18)/$3) > 0.5 {print $0}' > total_hmm.out.evalue3.cov50
rm *.hmmout


##Step 2: identify single-copy markers from query genomes; classify genome queries into family groups
echo $(date)"	Step 2: Identification of single-copy markers"

taxon_list="$installer_dir/database/reference_subfamily_list"

########## invoke another bash file to identify single-copy VOG markers in each query and to make alignment
cat $taxon_list|while read line
do
    cp $installer_dir/scripts/identification_of_markers_bacterial_and_archaeal_viruses.sh identification_of_markers_bacterial_and_archaeal_viruses_for_"$line".sh
done

for i in identification_of_markers_bacterial_and_archaeal_viruses_for_*
do
   taxa=$(echo $i|sed 's/identification_of_markers_bacterial_and_archaeal_viruses_for_//'|sed 's/\.sh//')
   echo "bash $i -a $wd/gene_calling/queries.protein.faa -b $wd/gene_calling/queries.raw -c $taxa -d $installer_dir/scripts -e $installer_dir/database/selected_single_copy_VOG_for_each_subfamily -f $wd/total_hmm.out.evalue3.cov50 -g $query_taxonomy -r $installer_dir/database/VOG_protein_sequences_at_FamilyOrSubfamily_rank -t $threads"
done > scriptset.sh

perl $scripts/multiple_threads.pl scriptset.sh -c $threads
rm identification_of_markers_bacterial_and_archaeal_viruses_for_*sh
mkdir genome_alignment
mv dir_of_*_alignment genome_alignment

for aln in *_ReferenceQuery_aln.fasta
do
    if [ -f "$aln" ]; then
	file="1"
    fi
done

##continue following steps if single-copy genes were detected
if [ "$file" = "1" ]; then
##Step 3: Replace genomes in reference trees using pplacer and assign taxonomy based on monophyly; make sure ete3 installed
echo $(date)"	Step 3: Genome replacement in reference trees"

mkdir tree_replacement_and_taxon_assignment
mv *_ReferenceQuery_aln.fasta tree_replacement_and_taxon_assignment
cd tree_replacement_and_taxon_assignment

for aln in *_ReferenceQuery_aln.fasta
do 
    line=$(echo $aln|sed 's/_ReferenceQuery_aln.fasta//')
    echo $(date)"	Preprocessing before classification for viruses in "$line""
    mkdir "$line"_temp_dir_for_species_assignment
    mkdir "$line"_temp_dir_for_genus_assignment
    pplacer --verbosity 0 -c $installer_dir/database/packages_for_pplacer/"$line".refpkg "$line"_ReferenceQuery_aln.fasta -o "$line"_ReferenceQuery.jplace
    guppy tog -o "$line"_ReferenceQuery.jplace.treefile "$line"_ReferenceQuery.jplace

    MonoPhylo="$installer_dir/scripts/MonoPhylo.py"
    Grouping_Key="$installer_dir/database/VMR_MSL38_v1_for_Grouping_Key.txt"
    reference_genomes="$installer_dir/database/reference_genomes.fasta"

    cat $wd/gene_calling/queries.num $reference_genomes|awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' > query_and_reference_genomes.fasta.tmp

    python $scripts/identify_monophyletic_groups.py "$line"_ReferenceQuery.jplace.treefile > "$line"_monophyletic_groups_with_seqID

    cp "$line"_monophyletic_groups_with_seqID "$line"_monophyletic_groups_with_seqID_for_genus_assignment

    cat $Grouping_Key|cut -f1,3|tail -n +2|while read ICTVtax
    do
        ID=$(echo $ICTVtax|sed 's/ .*//')
        taxon=$(echo $ICTVtax|sed 's/.* //')
        sed -i "s/"$ID"/"$taxon"/" "$line"_monophyletic_groups_with_seqID_for_genus_assignment
    done

########## assign genus
    grep 'query' "$line"_monophyletic_groups_with_seqID_for_genus_assignment|while read line1
    do
        group=$(echo $line1|sed 's/:.*//')
        genomes=$(echo $line1|sed 's/.*://')
        echo ">$group"
        echo $genomes|sed 's/, /\n/g'|sort -u|grep 'virus'|wc -l
    done|awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}'|sed 's/>//'|awk '$2==1{print $1}'|while read line2
        do
            grep -P "$line2:" "$line"_monophyletic_groups_with_seqID_for_genus_assignment
        done|while read line3
            do
                group=$(echo $line3|sed 's/:.*//')
                genomes=$(echo $line3|sed 's/.*://')
                echo $genomes|sed 's/, /\n/g'|sort -u|grep -v -w 'NA' > "$line"_temp_dir_for_genus_assignment/$group
            done

########## assign species
    grep 'query' "$line"_monophyletic_groups_with_seqID_for_genus_assignment|while read line1
    do
        group=$(echo $line1|sed 's/:.*//')
        genomes=$(echo $line1|sed 's/.*://')
        echo ">$group"
        echo $genomes|sed 's/, /\n/g'|sort -u|grep 'virus'|wc -l
    done|awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}'|sed 's/>//'|awk '$2==1{print $1}'|while read line2
        do
            grep -P "$line2:" "$line"_monophyletic_groups_with_seqID
        done|while read line3
            do
                group=$(echo $line3|sed 's/:.*//')
                genomes=$(echo $line3|sed 's/.*://')
                echo $genomes|sed 's/, /\n/g'|sort -u|grep -v -w 'NA' > "$line"_temp_dir_for_species_assignment/$group
            done

##Step 4: Genus classification
echo $(date)"	Step 4: Classification at genus rank"

    cd "$line"_temp_dir_for_genus_assignment
    count=`ls -1 Group_* 2>/dev/null | wc -l`
    if [ $count != 0 ]
    then
    for i in Group_*
        do
            grep 'virus' $i > virus_"$i"
        done

    for i in Group_*
        do
            grep -v 'virus' $i > query_"$i"
        done

    for i in virus_Group_*
        do
            j=$(echo $i|sed 's/virus_//')
            cat $i|while read line
            do
                sed -i "s/$/\t"$line"/" query_"$j"
            done
        done

    cat query_Group_*|sort -u > $wd/tree_replacement_and_taxon_assignment/"$line"_monophyletic_groups_with_seqID_for_genus_assignment_output
    fi
    cd $wd/tree_replacement_and_taxon_assignment

##Step 5: Species classification
echo $(date)"	Step 5: Classification at species rank"

    cd "$line"_temp_dir_for_species_assignment
    wd_species=`pwd`
    count=`ls -1 Group_* 2>/dev/null | wc -l`
    if [ $count != 0 ]
    then
    #####cluster species using fastANI
    for group in Group_*
    do
        mkdir "$group"_QueryGenome_dir
        mkdir "$group"_RefGenome_dir
        grep '^query' $group|while read genome
        do
            grep "$genome" $wd/tree_replacement_and_taxon_assignment/query_and_reference_genomes.fasta.tmp|sed 's/\t/\n/' > "$group"_QueryGenome_dir/"$genome".fasta
            echo ""$genome".fasta" >> "$group"_QueryGenome.list
            echo ""$wd_species"/"$group"_QueryGenome_dir/" >> "$group"_QueryGenome.path
        done
        paste "$group"_QueryGenome.path "$group"_QueryGenome.list | sed 's/\t//' > "$group"_QueryGenome_list_path
        grep -v '^query' $group|while read genome
        do
            grep "$genome" $wd/tree_replacement_and_taxon_assignment/query_and_reference_genomes.fasta.tmp|sed 's/\t/\n/' > "$group"_RefGenome_dir/"$genome".fasta
            echo ""$genome".fasta" >> "$group"_RefGenome.list
            echo ""$wd_species"/"$group"_RefGenome_dir/" >> "$group"_RefGenome.path
        done
        paste "$group"_RefGenome.path "$group"_RefGenome.list | sed 's/\t//' > "$group"_RefGenome_list_path
        #used with fastANI version 1.33
        fastANI --ql "$group"_QueryGenome_list_path \
                --rl "$group"_RefGenome_list_path \
                -o "$group"_fastani_output.txt \
                -t $threads \
                --fragLen 500 \
                --minFraction 0.8 \
		2> /dev/null

        awk '$1!=$2 && $3>=95{print $0}'  "$group"_fastani_output.txt |awk '{fraction=$4/$5} {print $1,$2,$3,fraction}'|awk '$4>=0.8{print $0}' > "$group"_fastani_output_species_classification
        cut -d ' ' -f1,2 "$group"_fastani_output_species_classification|sed 's/ .*//'|sed 's/.*\///'|sed 's/.fasta//' > "$group"_fastani_output_species_classification_col1
        cut -d ' ' -f1,2 "$group"_fastani_output_species_classification|sed 's/.* //'|sed 's/.*\///'|sed 's/.fasta//' > "$group"_fastani_output_species_classification_col2
        cut -d ' ' -f3,4 "$group"_fastani_output_species_classification > "$group"_fastani_output_species_classification_col34
        paste "$group"_fastani_output_species_classification_col1 "$group"_fastani_output_species_classification_col2 "$group"_fastani_output_species_classification_col34 > "$group"_fastani_output_species_classification2
        sort "$group"_fastani_output_species_classification2|awk 'BEGIN {name=""; highest_score=0} $1 != name {if (name != "") print line[highest_score]; name=$1; highest_score=0} $3*$4 >= highest_score {highest_score=$3*$4; line[highest_score]=$0} END {print line[highest_score]}'|sed 's/ /_/' > "$group"_fastani_output_species_classification2.besthit
    done
    fi

    cat *_fastani_output_species_classification2.besthit > total_fastani_output_species_classification2.besthit.tmp1
    cat total_fastani_output_species_classification2.besthit.tmp1|cut -f3|sed 's/_/\t/' > total_fastani_output_species_classification2.besthit.tmp2
    paste total_fastani_output_species_classification2.besthit.tmp1 total_fastani_output_species_classification2.besthit.tmp2|sort|awk 'BEGIN {name=""; highest_score=0} $1 != name {if (name != "") print line[highest_score]; name=$1; highest_score=0} $4*$5 >= highest_score {highest_score=$4*$5; line[highest_score]=$0} END {print line[highest_score]}'|sed 's/ /_/' > total_fastani_output_species_classification2.besthit
    cat $Grouping_Key|cut -f1,2|tail -n +2|while read ICTVtax
    do
        ICTVtax2=$(echo $ICTVtax|sed 's/ /__/')
        ID=$(echo $ICTVtax2|sed 's/__.*//')
        taxon=$(echo $ICTVtax2|sed 's/.*__//'|sed 's/ /_/g')
        sed -i "s/"$ID"/"$taxon"/" total_fastani_output_species_classification2.besthit
    done
    cp total_fastani_output_species_classification2.besthit $wd/tree_replacement_and_taxon_assignment/"$line"_monophyletic_groups_with_seqID_for_species_assignment_output
    cd $wd/tree_replacement_and_taxon_assignment

    rm -r "$line"_temp_dir_for_genus_assignment
    rm -r "$line"_temp_dir_for_species_assignment
done

cat *monophyletic_groups_with_seqID_for_genus_assignment_output|grep 'query' > $wd/query_genus_assignment_output
cat *monophyletic_groups_with_seqID_for_species_assignment_output > $wd/query_species_assignment_output

cd $wd
perl $scripts/queries2rawSeqID.pl gene_calling/queries.raw query_genus_assignment_output > query_genus_assignment_output_with_accession
perl $scripts/queries2rawSeqID.pl gene_calling/queries.raw query_species_assignment_output > query_species_assignment_output_with_accession

cut -f1,2 query_species_assignment_output|sed 's/_/ /'|grep '\S' > query_species_assignment_output2
cat query_species_assignment_output2 query_genus_assignment_output |sort |grep '\S' |cut -f1 |sort -u > query_species_genus_assignment_output_queryID

perl $scripts/harh_for_mapping.pl query_genus_assignment_output query_species_genus_assignment_output_queryID > query_genus_assignment_output_for_paste

perl $scripts/harh_for_mapping.pl query_species_assignment_output2 query_species_genus_assignment_output_queryID > query_species_assignment_output2_for_paste
sed 's/ /_/g' query_species_assignment_output2_for_paste > query_species_assignment_output2_for_paste2

paste query_species_assignment_output2_for_paste2 query_genus_assignment_output_for_paste |cut -f1,2,4,6|sed 's/\t/@@/'|grep -v '@@NA'|while read line
    do
        q=$(echo $line|sed 's/ /\t/g'|sed 's/query.*\@\@//'|sed 's/_/ /g')
        echo "$line"
        grep -w "$q" $installer_dir/database/VMR_MSL38_v1_for_Grouping_Key_with_reference_marks.txt
    done|awk 'BEGIN{RS="query"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}'|grep 'Reference_'|cut -f1-2,6-13|sed 's/\@\@/\t/'|sed 's/_/ /g' > query_classification_with_species_information

paste query_species_assignment_output2_for_paste2 query_genus_assignment_output_for_paste |cut -f1,2,4,6|sed 's/\t/@@/'|grep '@NA'|while read line
    do
        q=$(echo $line|sed 's/ /\t/g'|sed 's/query.*\@\@NA\t//')
        echo "$line"
        grep -w "$q" $installer_dir/database/VMR_MSL38_v1_for_Grouping_Key_with_reference_marks.txt
    done|awk 'BEGIN{RS="query"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}'|grep 'Reference_'|cut -f1-2,6-13|sed 's/\@\@/\t/'|sed 's/NA/Unassigned/' > query_classification_without_species_information

##Step 6: final lineage assignment
echo $(date)"	Step 6: Final lineage assignment"

cat query_classification_with_species_information query_classification_without_species_information > query_classification
perl $scripts/queries2rawSeqID.pl gene_calling/queries.raw query_classification|cut -f1,3- > sequences_with_classification_tmp
sed '1 i\Query\tSpecies\tGenus\tSubfamily\tFamily\tOrder\tClass\tPhylum\tKingdom\tRealm' sequences_with_classification_tmp > sequences_with_classification.txt
mv sequences_with_classification.txt final_taxonomic_assignment.txt
rm sequences_with_classification* query_classification* query_*_assignment_output* total_hmm.out.evalue3.cov50 hmmsearch_batch.sh scriptset.sh

##Assignment finished
echo $(date)"	Assignment finished"
echo $(date)"	Thanks for using vClassifier"
echo ====================================================================================================

##discontinue steps 3-7 if query sequences lack specific single-copy genes
else
rm hmmsearch_batch.sh scriptset.sh total_hmm.out.evalue3.cov50
echo $(date)"	Assignment was discontinued due to the lack of specific single-copy genes in the query sequences"
echo $(date)"	Thanks for using vClassifier"
echo ====================================================================================================
fi
