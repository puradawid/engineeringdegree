#!/bin/sh

# (C)2010 Marcin Skoczylas
# warning: convert multiple pages at one from pdf to png does not work properly (imagemagick bug)
# thus this script converts each page separately

if [ "$1" = "" ]
then
	echo "Usage: pdfs2png.sh <name> [DPI=600] [NUM_THREADS=4] [count start=0]"
	exit;
fi

if [ "$2" = "" ]
then
	DPI=600
else
	DPI=$2
fi


if [ "$3" = "" ]
then
	NUM_THREADS=4
else
	NUM_THREADS=$3
fi

if [ "$4" = "" ]
then
	count=0
else
	count=$4
fi

mkdir $1

numProc=0
for pdf in `ls -1 *.pdf|sort`; do
	echo Processing $pdf
	numPages=`identify -format "%n" $pdf`
	echo Converting $numPages pages:
	for ((page=0; page < $numPages; page++)); do
		#echo ...page $page
		pad=`printf '%05d' $count`
		echo convert -layers flatten -density "$DPI"x"$DPI" $pdf[$page] ./$1/$1-$pad.png
		convert -density "$DPI"x"$DPI" $pdf[$page] ./$1/$1-$pad.png &
		count=$((count+1))
		numProc=$(($numProc+1))
		if [ "$numProc" -ge "$NUM_THREADS" ]; then
			wait
			numProc=0
		fi
	done
done

#count=`expr $count + 1`;

