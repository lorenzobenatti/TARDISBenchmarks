#!/bin/sh

echo "[UNZIP AND COMPILE SCRIPT] STARTING at $(date)"

#Unzip all benchmarks?
echo "[UNZIP AND COMPILE SCRIPT] Unzip all benchmarks? [y]es , [n]o"
read UnzipBenchmarks
if [ $UnzipBenchmarks == "y" ]; then
	echo "[UNZIP AND COMPILE SCRIPT] Unzipping all benchmarks..."
	for z in *.zip
	do
		if [ $z == "zxingSplit.zip" ]; then
			cat zxingSplit.z01 zxingSplit.zip > zxing_joined.zip && unzip zxing_joined.zip && echo "[UNZIP AND COMPILE SCRIPT] $z unzipped" || echo "[UNZIP AND COMPILE SCRIPT] $z: Failed"
		elif [ $z == "pdfboxSplit.zip" ]; then
			zip -F pdfboxSplit.zip --out pdfbox.zip && unzip pdfbox.zip && echo "[UNZIP AND COMPILE SCRIPT] $z unzipped" || echo "[UNZIP AND COMPILE SCRIPT] $z: Failed"
		elif [ $z == "guava9thSplit.zip" ]; then
			zip -F guava9thSplit.zip --out guava9th.zip && unzip guava9th.zip && echo "[UNZIP AND COMPILE SCRIPT] $z unzipped" || echo "[UNZIP AND COMPILE SCRIPT] $z: Failed"
		else
			unzip $z && echo "[UNZIP AND COMPILE SCRIPT] $z unzipped" || echo "[UNZIP AND COMPILE SCRIPT] $z: Failed"
		fi
	done
fi

#Compile all benchmarks?
echo "[UNZIP AND COMPILE SCRIPT] Compile all benchmarks? [y]es , [n]o"
read CompileBenchmarks
if [ $CompileBenchmarks == "y" ]; then
	echo "[UNZIP AND COMPILE SCRIPT] Compiling all benchmarks..."
	for d in */
	do
		if [ $d != "RunFiles/" ]; then
    		cd $d && mvn compile && echo "[UNZIP AND COMPILE SCRIPT] $d compiled" || echo "[UNZIP AND COMPILE SCRIPT] $d: Failed"
    		cd .. 
    	fi
	done
fi

bash CompileAndMove.sh

echo "[UNZIP AND COMPILE SCRIPT] ENDING at $(date)"
