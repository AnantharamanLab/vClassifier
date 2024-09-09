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
   echo "identification of single-copy genes of bacterial and archaeal viruses"
   echo 
   echo "Usage: bash identification_of_markers_bacterial_and_archaeal_viruses.sh [options]"
   echo "options:"
   echo "-a          Query protein sequences."
   echo "-b          Query genomes."
   echo "-c          Reference families or subfamilies."
   echo "-e          VOGs of reference families or subfamilies."
   echo "-f          Total hmmout of query sequences"
   echo "-g          Taxonomy of query sequences"
   echo "-r          Directory of reference"
   echo "-t          Number of threads used for parallel running"
   echo "-d          Path of installed scripts"
   echo "-h          Show help on version and usage"
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

while getopts :ha:b:c:d:e:f:g:r:t: option
do
    case "${option}" in
        a) query_viral_protein=${OPTARG};;
        b) query_genome=${OPTARG};;
	c) taxon=${OPTARG};;
	d) scripts=${OPTARG};;
	e) VOG_for_each_taxon=${OPTARG};;
	f) total_hmmout=${OPTARG};;
	g) query_taxon=${OPTARG};;
	r) reference_dir=${OPTARG};;
        t) threads=${OPTARG};;
	h) Help
	   exit;;
	\?) echo "Error: Invalid option."
	   exit;;
    esac
done

wd1=`pwd`

mkdir dir_of_"$taxon"_alignment
cd dir_of_"$taxon"_alignment
wd2=`pwd`
awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $query_viral_protein > query_viral_genomes_protein.faa.tmp

#extract genomes from hmm.out.evalue3.cov50
perl $scripts/rawSeqID2queries.pl $query_genome $query_taxon > query_taxon
grep -w "$taxon" query_taxon | awk '{print $1}' > genomes_in_the_"$taxon"

cat genomes_in_the_"$taxon"|while read line
do
    grep -P "^"$line"_" $total_hmmout
done > "$taxon"_hmm.out.evalue3.cov50

#select genomes of a specific taxon
grep -w "$taxon" $VOG_for_each_taxon|cut -f2|while read line
do
    grep -w "$line" "$taxon"_hmm.out.evalue3.cov50
done > total_hmm.out.evalue3.cov50

#continue analyzing if total_hmm.out.evalue3.cov50 size > 0
if [[ ! -s total_hmm.out.evalue3.cov50 ]] ; then
          exit 1

else
#  FILE has some data, so we can continue...
sed 's/_/ /' total_hmm.out.evalue3.cov50|awk 'BEGIN {FS=" "; name=""; highest_score=0} $1 != name {if (name != "") print line[highest_score]; name=$1; highest_score=0} $9 >= highest_score {highest_score=$9; line[highest_score]=$0} END {print line[highest_score]}'|sed 's/ /_/' > total_hmm.out.evalue3.cov50.besthit
cat total_hmm.out.evalue3.cov50.besthit |awk '{print $1"\t"$4"\t"$1}'|sed 's/>//'|sed 's/_.*VOG/\tVOG/' > total_hmm.out.evalue3.cov50.besthit.simple.format.with.genomeID.markers

#extract protein sequences
cat total_hmm.out.evalue3.cov50.besthit.simple.format.with.genomeID.markers|cut -f2|sort -u|while read line
do
    grep -w "$line" total_hmm.out.evalue3.cov50.besthit.simple.format.with.genomeID.markers >> "$line".protein
done

# remove multicopy genes
for i in VOG*.protein
do
    perl $scripts/retain_only_one_single_copy_gene.pl $i $i.uniq
    rm $i
    mv $i.uniq $i
done

for i in VOG*.protein
do
    echo "cut -f3 $i|while read line;do grep -w "\$line" $wd2/query_viral_genomes_protein.faa.tmp;done|sed 's/\t/\n/' > "$i".fasta"
done > extract_sequence.sh

perl $scripts/multiple_threads.pl extract_sequence.sh -c $threads
mkdir temp_for_VOG_protein
mv VOG*.protein.fasta temp_for_VOG_protein
cd $reference_dir/"$taxon"_dir

for i in VOG*.protein.fasta
do
    if [ -f $wd2/temp_for_VOG_protein/$i ]; then
	cat $i $wd2/temp_for_VOG_protein/$i > $wd2/$i
    else
	cat $i > $wd2/$i
    fi
done

cd $wd2

#align multiple sequences using mafft and trimal
for i in VOG*.protein.fasta
do
    mafft --quiet --adjustdirectionaccurately --thread $threads --auto $i > "$i".msa
done

for i in *msa
do
    trimal -in $i -out "$i".trimal -gt 0.5
done

for i in *trimal
do
    sed 's/_.*//' "$i" > "$i".with.genomeID
done

cat *protein.fasta.msa.trimal.with.genomeID|grep '^>'|cut -d '-' -f1|sed 's/>//'|sort -u > total_genomeID_from_trimal

for i in *.protein.fasta.msa.trimal.with.genomeID
do
    perl $scripts/harh_for_fasta.pl $i > "$i".tmp
done

for i in *.protein.fasta.msa.trimal.with.genomeID.tmp
    do j=$(echo $i|sed 's/.tmp//')
    perl $scripts/extrac_seq_and_introduce_gaps.pl $i total_genomeID_from_trimal > "$j".for.concatenation
done

ls -lh VOG*for.concatenation|awk '{print $9}'|perl -p -e 's/\n/ /g' |sed 's/^/paste /'| sed 's/$/ > total.tmp/' > paste.sh
bash paste.sh
cat total.tmp| sed 's/\t//g'|sed 's/>/</'|sed 's/>.*//'|sed 's/^</>/' > total.protein.fasta.msa.trimal.with.genomeID.for.concatenation
cp total.protein.fasta.msa.trimal.with.genomeID.for.concatenation $wd1/"$taxon"_ReferenceQuery_aln.fasta
#rm ../query_viral_genomes_protein.faa.tmp

cd $wd1

fi
