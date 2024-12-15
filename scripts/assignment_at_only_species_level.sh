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
        i) group=${OPTARG};;
        l) wd=${OPTARG};;
        t) threads=${OPTARG};;
	p) installer_dir=${OPTARG};;
	h) Help
	   exit;;
	\?) echo "Error: Invalid option."
	   exit;;
    esac
done

##Species classification
	wd_species=`pwd`
        mkdir "$group"_QueryGenome_dir
        mkdir "$group"_RefGenome_dir

        grep '^query' $group|while read genome
        do
            echo ""$genome".fasta" >> "$group"_QueryGenome.list
            echo ""$wd_species"/"$group"_QueryGenome_dir/" >> "$group"_QueryGenome.path
        done
        paste "$group"_QueryGenome.path "$group"_QueryGenome.list | sed 's/\t//' > "$group"_QueryGenome_list_path
	perl $installer_dir/scripts/harh_for_seq_extraction.pl $wd/tree_replacement_and_taxon_assignment/query_and_reference_genomes.fasta "$group"_QueryGenome.list "$group"_QueryGenome_dir

        grep -v '^query' $group|while read genome
        do
            echo ""$genome".fasta" >> "$group"_RefGenome.list
            echo ""$wd_species"/"$group"_RefGenome_dir/" >> "$group"_RefGenome.path
        done
        paste "$group"_RefGenome.path "$group"_RefGenome.list | sed 's/\t//' > "$group"_RefGenome_list_path
	perl $installer_dir/scripts/harh_for_seq_extraction.pl $wd/tree_replacement_and_taxon_assignment/query_and_reference_genomes.fasta "$group"_RefGenome.list "$group"_RefGenome_dir

        #used with fastANI version 1.33
        fastANI --ql "$group"_QueryGenome_list_path \
                --rl "$group"_RefGenome_list_path \
                -o "$group"_fastani_output.txt \
                -t $threads \
                --fragLen 500 \
                --minFraction 0.8 \
		2> /dev/null
	if [ -f ""$group"_fastani_output.txt" ]; then
        awk '$1!=$2 && $3>=95{print $0}'  "$group"_fastani_output.txt |awk '{fraction=$4/$5} {print $1,$2,$3,fraction}'|awk '$4>=0.8{print $0}' > "$group"_fastani_output_species_classification

        if [ -s ""$group"_fastani_output_species_classification" ]; then
        cut -d ' ' -f1,2 "$group"_fastani_output_species_classification|sed 's/ .*//'|sed 's/.*\///'|sed 's/.fasta//' > "$group"_fastani_output_species_classification_col1
        cut -d ' ' -f1,2 "$group"_fastani_output_species_classification|sed 's/.* //'|sed 's/.*\///'|sed 's/.fasta//' > "$group"_fastani_output_species_classification_col2
        cut -d ' ' -f3,4 "$group"_fastani_output_species_classification > "$group"_fastani_output_species_classification_col34
        paste "$group"_fastani_output_species_classification_col1 "$group"_fastani_output_species_classification_col2 "$group"_fastani_output_species_classification_col34 > "$group"_fastani_output_species_classification2
        sort "$group"_fastani_output_species_classification2|awk 'BEGIN {name=""; highest_score=0} $1 != name {if (name != "") print line[highest_score]; name=$1; highest_score=0} $3*$4 >= highest_score {highest_score=$3*$4; line[highest_score]=$0} END {print line[highest_score]}'|sed 's/ /_/' > "$group"_fastani_output_species_classification2.besthit
	fi

	fi
