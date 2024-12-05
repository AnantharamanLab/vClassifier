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
   echo "-i     Input."
   echo "-l     Folder containing the folder gene_calling."
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
        i) line=${OPTARG};;
        l) wd=${OPTARG};;
        t) threads=${OPTARG};;
	p) installer_dir=${OPTARG};;
	h) Help
	   exit;;
	\?) echo "Error: Invalid option."
	   exit;;
    esac
done

    scripts="$installer_dir/scripts"

    echo $(date)"	Preprocessing before classification for "$line" viruses"
    mkdir "$line"_temp_dir_for_species_assignment
    mkdir "$line"_temp_dir_for_genus_assignment

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
echo $(date)"	Step 4: Classification for "$line" viruses at genus rank"

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
echo $(date)"	Step 5: Classification for "$line" viruses at species rank"

    cd "$line"_temp_dir_for_species_assignment
    count=`ls -1 Group_* 2>/dev/null | wc -l`
    if [ $count != 0 ]
    then
    for group in Group_*
    do
        echo "bash $installer_dir/scripts/assignment_at_only_species_level.sh -i $group -l $wd -p $installer_dir -t $threads"
    done > classification_batch_for_viral_species.sh
    perl $scripts/multiple_threads.pl classification_batch_for_viral_species.sh -c $threads   

    count=`ls -1 Group_*_fastani_output_species_classification2.besthit 2>/dev/null | wc -l`
    if [ $count != 0 ]
    then
    cat Group_*_fastani_output_species_classification2.besthit > total_fastani_output_species_classification2.besthit.tmp1
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
    fi

    fi

    cd $wd/tree_replacement_and_taxon_assignment

    rm -r "$line"_temp_dir_for_genus_assignment
    rm -r "$line"_temp_dir_for_species_assignment
