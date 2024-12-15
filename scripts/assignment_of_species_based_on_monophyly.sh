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

while getopts :hi:d:f: option
do
    case "${option}" in
        i) line=${OPTARG};;
	d) dir=${OPTARG};;
	f) file=${OPTARG};;
	h) Help
	   exit;;
	\?) echo "Error: Invalid option."
	   exit;;
    esac
done

########## assign species
    grep 'query' $line|while read line1
    do
        group=$(echo $line1|sed 's/:.*//')
        genomes=$(echo $line1|sed 's/.*://')
        echo ">$group"
        echo $genomes|sed 's/, /\n/g'|sort -u|grep 'virus'|wc -l
    done|awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}'|sed 's/>//'|awk '$2==1{print $1}'|while read line2
        do
            grep -P "$line2:" $dir/$file
        done|while read line3
            do
                group=$(echo $line3|sed 's/:.*//')
                genomes=$(echo $line3|sed 's/.*://')
                echo $genomes|sed 's/, /\n/g'|sort -u|grep -v -w 'NA' > $group
            done


