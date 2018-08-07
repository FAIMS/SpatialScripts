#!/bin/bash 

set -euo pipefail  # unofficial bash strict mode, makes code more maintenable and reliable, see http://redsymbol.net/articles/unofficial-bash-strict-mode/

if [ "$#" -ne 2 ]; then  # if number of arguments is not equal to two
	echo "./makeRasters.sh  targetDir targetEPSG $#"  #
	exit 1
fi

find $1 -name "*.tif" -type f  # print names of tiff files

rm -rf $1/maps  #remove if there already is a maps folders
mkdir $1/maps  # create new directory

parallel --will-cite "gdalwarp -co TILED=YES -t_srs EPSG:$2 {} {//}/maps/{/.}.$2.tif;  gdaladdo -r nearest {//}/maps/{/.}.$2.tif 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192" ::: $(find $1 -name "*.tif" -type f)
#if you run GNU parallel it requires being cited ; {} is part of parallel - look it up
#gdalwarp till ; reprojects the files and tiles the result
#stuff after ::: denotes the files on which the operations can be run
# variable $1 is the targetDir, variable $2 is the target EPSG  
cd $1 
tar -czf maps.$1.$2.tar.gz maps/

# to give the script permission to access files via $ chmod +x ./scriptname
# to run the script run with source directory as a child of current location and epsg.