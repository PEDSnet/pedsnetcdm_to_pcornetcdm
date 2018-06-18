#!/usr/bin/env bash

path_out=$( pwd | sed 's/bash_script/data/g' )
file_name="/concept_map.csv"
dir_name="/concept_map/*.csv"
OutFileName=$path_out$file_name              # Fix the output name
loop_file=$path_out$dir_name
i=0                                       # Reset a counter
for filename in $loop_file; do
 echo $filename
 if [ "$filename"  != "$OutFileName" ] ;      # Avoid recursion
 then
   if [[ $i -eq 0 ]] ; then
      head -1  $filename >   $OutFileName # Copy header if it is the first file
   fi
   tail -n +2  $filename >>  $OutFileName # Append from the 2nd line each file
   i=$(( $i + 1 ))                        # Increase the counter
 fi
done

var="source_concept_class,target_concept,pcornet_name,source_concept_id,concept_description,value_as_concept_id"
sed -i '' "1s/.*/$var/" $OutFileName
