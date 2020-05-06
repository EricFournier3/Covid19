#!/bin/bash

#TODO wget au lieu de copy

work_dir=$1"/"
temp_dir=${work_dir}"temp/"
config_dir=${work_dir}"config"/
data_dir=${work_dir}"data/"
script_dir=${work_dir}"scripts/"
init_file=${work_dir}"init.txt"
create_new_config_script=${script_dir}"CreateNextstrainConfigV3.py"

lat_long_out=${config_dir}"lat_longs.tsv"
ordering_out=${config_dir}"ordering.tsv"

nextstrain_files_base_dir="/data/Applications/GitScript/Covid19/NextStrainFiles/"


BuildFramework(){
   echo "In BuildFrameWork"

   touch ${init_file}
   mkdir ${temp_dir}
   
}

TransferConfigFiles(){
  #TODO wget
  ext=(".txt" ".tsv" ".json")

  for _ext in ${ext[@]}
    do
    cp "${nextstrain_files_base_dir}config/"*"${_ext}" ${config_dir}
  done 

}

TransferScripts(){
  ext=(".py" ".sh")

  for _ext in ${ext[@]}
    do
    cp "${nextstrain_files_base_dir}scripts/"*"${_ext}" ${script_dir}
  done
}


ImportLatLong(){
  wget https://raw.githubusercontent.com/nextstrain/ncov/master/config/lat_longs.tsv -O ${temp_dir}"lat_longs.tsv" 1>/dev/null  2>&1
}

CreateNewConfigFiles(){
  python ${create_new_config_script} --lat-long-out ${lat_long_out} --ordering-out ${ordering_out} --base-dir ${work_dir} 
}

if ! [ -f ${init_file} ]
  then
  BuildFramework
  TransferConfigFiles
  TransferScripts
  ImportLatLong
  CreateNewConfigFiles
fi


#TODO a modifier
cp /data/Applications/GitScript/Covid19/NextStrainFiles/data/metadata.tsv /data/PROJETS/COVID_19/TestCtSmall/data
cp /data/Applications/GitScript/Covid19/NextStrainFiles/data/sequences.fasta /data/PROJETS/COVID_19/TestCtSmall/data

exit 0

echo "Work dir is ${work_dir}"

if ! [ -d ${temp_dir} ]
  then
  mkdir ${temp_dir}
fi

nextstrain_git="https://github.com/nextstrain/ncov.git"
local_git="${work_dir}/temp/ncov/"
nextstrain_files_base_dir="/data/Applications/GitScript/Covid19/NextStrainFiles/"
lat_long_ori="${temp_dir}lat_longs.tsv"

missing_sgil_countries=${nextstrain_files_base_dir}"config/MissingSgilCountries.tsv"
country_lat_long="${nextstrain_files_base_dir}config/country_lat_long.tsv"
division_lat_long="${nextstrain_files_base_dir}config/division_lat_long.tsv"

lat_long_new="../config/lat_longs.tsv"
ordering_new="../config/ordering.tsv"



#awk 'BEGIN{FS="\t"}/country/{print $2"\t"$3"\t"$4}' ${lat_long_ori} > ${country_lat_long}
#cat ${missing_sgil_countries} >> ${country_lat_long}
#awk 'BEGIN{FS="\t"}/division/{print $2"\t"$3"\t"$4}' ${lat_long_ori} > ${division_lat_long}



#if [ -d "${local_git}" ]
#  then
  :
#else
#  sudo git clone ${nextstrain_git} ${local_git}
#fi


if ! [ -f ${lat_long_ori} ]
  then
  wget https://raw.githubusercontent.com/nextstrain/ncov/master/config/lat_longs.tsv -O ${temp_dir}"lat_longs.tsv"
fi


#python CreateNextstrainConfigV3.py --lat-long-out  
