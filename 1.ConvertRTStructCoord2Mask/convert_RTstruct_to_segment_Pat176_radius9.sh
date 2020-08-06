

main() {
	DIR_BIN=/mnt/md1/Christian/Software/c3d-1.1.0-Linux-x86_64/bin/
    C3D="$DIR_BIN/c3d"
    DIR_DATA=/mnt/md1/Christian/Projects/MEGRE/Patients176processed
    DIR_INTERIM=/mnt/md1/Christian/Projects/MEGRE/Patients176/
    find_DIR_INTERIM=$(find $DIR_INTERIM -mindepth 1 -maxdepth 1 -type d)
    for pat in $find_DIR_INTERIM
    do
        echo $pat
        find_rtstruct=$(find $pat/ -name 'RS*.dcm' )
        number=${find_rtstruct#*Patients176/}
        number=${number%_noAnon*}
        number=${number#Pat}
        echo this is supposed to be a number: $number
        image=$DIR_DATA/echo_1/Pat${number}_echo-1.nii.gz
        echo $image
            
        DIR_OUT=$DIR_DATA/GT9
        mkdir -p $DIR_OUT
        convert_rtstruct $find_rtstruct $image $number $DIR_OUT
    done
}

convert_rtstruct() {

    RTSTRUCT=$1
    image=$2
    number=$3
    DIR_OUT=$4
    #coords=$(${DCMDUMP} ${RTSTRUCT} | grep "(3006,0050)")
    dcmdump ${RTSTRUCT} > dcmdump_RT.txt
    sed -i 's/\\/ /g' dcmdump_RT.txt
    coords=$(grep ContourData dcmdump_RT.txt | cut -d[ -f2 | cut -d] -f1)
    echo $coords

    ctr=1
    temp=""
    rm test.txt
    for coord in ${coords}
    do
      echo "Ctr= $ctr"
      if [[ $ctr < 3 ]]
      then
        val=$(echo "-1*$coord" | bc )
        temp="$temp $val"
      else
        temp="$temp $coord"
      fi

      if [[ $ctr == 3 ]];
      then
        echo "$temp 1"
        echo "$temp 1"  >> test.txt
        temp=""
        ctr="0"
      fi
      ctr=$(( $ctr + 1 ))
    done

    ${C3D} "$image" -scale 0 -landmarks-to-spheres "test.txt" 9 -o $DIR_OUT/Pat${number}_coords".nii.gz"
}
main "$@"
