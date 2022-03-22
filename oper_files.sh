#!/bin/bash
i=0
iter=10 #262144 
operType=$1
mkdir -p test_data/

# take 1.352sec if only while-loop for 262144, so slow
#while [ $i -lt $iter ]
#do
#    i=$(($i+1))
#done

case $operType in
    "write" )
        while [ $i -lt $iter ]
        do
            i=$(($i+1))
            echo $i > test_data/file_$i
        done;;
    "lsstat" )
        ls -la test_data/ > /dev/null;;
    "du_sh" )
        du -sh;;
    "read" )
        find ./test_data/ -name "file_*" | xargs cat > /dev/null;;
    "remove" )
        rm test_data/file_*;;
    * )
        echo wrong operType "$operType"
        exit -2;;
esac
