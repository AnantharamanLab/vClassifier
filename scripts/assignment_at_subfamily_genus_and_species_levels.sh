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
   echo "Usage: vClassifier_family [-i|-l|-t|-p|-h]"
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
    mkdir "$line"_temp_dir_for_subfamily_assignment

    MonoPhylo="$installer_dir/scripts/MonoPhylo.py"
    Grouping_Key="$installer_dir/database/VMR_MSL38_v1_for_Grouping_Key.txt"
    reference_genomes="$installer_dir/database/reference_genomes.fasta"

    cat $wd/gene_calling/queries.num $reference_genomes > query_and_reference_genomes.fasta

    python $scripts/identify_monophyletic_groups.py "$line"_ReferenceQuery.jplace.treefile > "$line"_monophyletic_groups_with_seqID

    cp "$line"_monophyletic_groups_with_seqID "$line"_monophyletic_groups_with_seqID_for_subfamily_assignment
    cp "$line"_monophyletic_groups_with_seqID "$line"_monophyletic_groups_with_seqID_for_genus_assignment

    wd_tmp=`pwd`
    cd "$line"_temp_dir_for_subfamily_assignment
    awk 'BEGIN {n=0;} /^Group/ {if(n%100==0){file=sprintf("chunk%d.subfamily.txt",n);} print >> file; n++; next;} { print >> file;}' < $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_subfamily_assignment

    for i in chunk*.subfamily.txt
    do
	echo "cat $Grouping_Key|cut -f1,4|tail -n +2|while read ICTVtax; do ID=\$(echo \$ICTVtax|sed 's/ .*//'); taxon=\$(echo \$ICTVtax|sed 's/.* //'); sed -i \"s/\"\$ID\"/\"\$taxon\"/\" $i; done"
    done > ICTVtax_"$line"_subfamily_batch.sh

    perl $scripts/multiple_threads.pl ICTVtax_"$line"_subfamily_batch.sh -c $threads
    cat chunk*.subfamily.txt > "$line"_monophyletic_groups_with_seqID_for_subfamily_assignment
    rm $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_subfamily_assignment
    mv "$line"_monophyletic_groups_with_seqID_for_subfamily_assignment $wd_tmp
    rm chunk*.subfamily.txt
    cd $wd_tmp

    cd "$line"_temp_dir_for_genus_assignment
    awk 'BEGIN {n=0;} /^Group/ {if(n%100==0){file=sprintf("chunk%d.genus.txt",n);} print >> file; n++; next;} { print >> file;}' < $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_genus_assignment

    for i in chunk*.genus.txt
    do
	echo "cat $Grouping_Key|cut -f1,3|tail -n +2|while read ICTVtax; do ID=\$(echo \$ICTVtax|sed 's/ .*//'); taxon=\$(echo \$ICTVtax|sed 's/.* //'); sed -i \"s/\"\$ID\"/\"\$taxon\"/\" $i; done"
    done > ICTVtax_"$line"_genus_batch.sh

    perl $scripts/multiple_threads.pl ICTVtax_"$line"_genus_batch.sh -c $threads
    cat chunk*.genus.txt > "$line"_monophyletic_groups_with_seqID_for_genus_assignment
    rm chunk*.genus.txt
    rm $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_genus_assignment
    mv "$line"_monophyletic_groups_with_seqID_for_genus_assignment $wd_tmp
    cd $wd_tmp

########## assign subfamily
    cd "$line"_temp_dir_for_subfamily_assignment
    awk 'BEGIN {n=0;} /^Group/ {if(n%100==0){file=sprintf("chunk%d.subfamily.txt",n);} print >> file; n++; next;} { print >> file;}' < $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_subfamily_assignment

    for i in chunk*.subfamily.txt
    do
	echo "bash $installer_dir/scripts/assignment_of_subfamily_based_on_monophyly.sh -i $i"
    done > subfamily_assignment_batch.sh

    perl $scripts/multiple_threads.pl subfamily_assignment_batch.sh -c $threads
    cd $wd_tmp

########## assign genus
    cd "$line"_temp_dir_for_genus_assignment
    awk 'BEGIN {n=0;} /^Group/ {if(n%100==0){file=sprintf("chunk%d.genus.txt",n);} print >> file; n++; next;} { print >> file;}' < $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_genus_assignment

    for i in chunk*.genus.txt
    do
	echo "bash $installer_dir/scripts/assignment_of_genus_based_on_monophyly.sh -i $i"
    done > genus_assignment_batch.sh

    perl $scripts/multiple_threads.pl genus_assignment_batch.sh -c $threads
    cd $wd_tmp

########## assign species
    cd "$line"_temp_dir_for_species_assignment
    awk 'BEGIN {n=0;} /^Group/ {if(n%100==0){file=sprintf("chunk%d.species.txt",n);} print >> file; n++; next;} { print >> file;}' < $wd_tmp/"$line"_monophyletic_groups_with_seqID_for_genus_assignment

    for i in chunk*.species.txt
    do
	echo "bash $installer_dir/scripts/assignment_of_species_based_on_monophyly.sh -i $i -d $wd_tmp -f "$line"_monophyletic_groups_with_seqID"
    done > species_assignment_batch.sh

    perl $scripts/multiple_threads.pl species_assignment_batch.sh -c $threads
    cd $wd_tmp

##Step 4: Subfamily classification
echo $(date)"	Step 4: Classification for "$line" viruses at subfamily rank"

    cd "$line"_temp_dir_for_subfamily_assignment
    count=`ls -1 Group_* 2>/dev/null | wc -l`
    if [ $count != 0 ]
    then 
    for i in Group_*
        do
            grep 'virinae' $i > virinae_"$i"
        done

    for i in Group_*
        do
            grep -v 'virinae' $i > query_"$i"
        done

    for i in virinae_Group_*
        do
            j=$(echo $i|sed 's/virinae_//')
            cat $i|while read line
            do
                sed -i "s/$/\t"$line"/" query_"$j"
            done
        done
    cat query_Group_*|sort -u > $wd/tree_replacement_and_taxon_assignment/"$line"_monophyletic_groups_with_seqID_for_subfamily_assignment_output
    fi
    cd $wd/tree_replacement_and_taxon_assignment

##Step 5: Genus classification
echo $(date)"	Step 5: Classification for "$line" viruses at genus rank"

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

##Step 6: Species classification
echo $(date)"	Step 6: Classification for "$line" viruses at species rank"

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
    rm -r "$line"_temp_dir_for_subfamily_assignment
    rm -r "$line"_temp_dir_for_species_assignment
