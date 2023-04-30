#!/bin/sh
echo "[TARDIS LAUNCHER] STARTING at $(date)"

# -------------------------------------------------------------------------------
# Edit TARDIS_HOME_PATH, Z3_PATH, REPO_HOME_PATH, GRADLE_REPO_PATH, LOG_PATH 
# and TOOLSJAR_PATH to reflect the paths where you installed the code:

# TARDIS_HOME_PATH: Folder where TARDIS is installed
# Z3_PATH:          Folder where Z3 is installed
# REPO_HOME_PATH:   Home folder of this repository
# GRADLE_REPO_PATH: Gradle folder
# LOG_PATH:         Folder where you want to save the TARDIS logs
# TOOLSJAR_PATH:    tools.jar path

TARDIS_HOME_PATH=/dev/hd2/tardisBenatti
Z3_PATH=/dev/hd2/usr/opt/z3/z3-4.8.9-x64-ubuntu-16.04/bin/z3
REPO_HOME_PATH=/dev/hd2/TARDISBenchmarks
GRADLE_REPO_PATH=/dev/hd2/usr/.gradle
LOG_PATH=/dev/hd2/TARDISBenchmarks/tardis-out
TOOLSJAR_PATH=/dev/hd2/usr/lib/jvm/jdk1.8.0_261/lib
#____________________________________________________________________________

# -------------------------------------------------------------------------------
# Editable variables:

# Set javaMem variable with xmx and/or xms value (-Xms16G -Xmx16G)
javaMem="-Xms16G -Xmx16G -Xss1G"
# Set sizeThreshold variable to choose the maximum size (MB) of tardis-tmp 
# folders. Tmp folders will be deleted if the size is greater than sizeThreshold.
sizeThreshold=1000
# Set timeoutThreshold variable to decide after how many minutes kill the 
# execution if still running after $globalTime minutes
timeoutThreshold=1
# Set doubleCoverageCalculation to 1 to perform a double coverage calculation:
# 1) coverage of the seeds test only 2) coverage of all the tests generated.
# If doubleCoverageCalculation != 1 only the second one is performed.
doubleCoverageCalculation=1
# Set systemlogging to 1 to save system load data in systemLog.csv file.
systemlogging=1
# -------------------------------------------------------------------------------

if [ $timeoutThreshold -lt 0 ]; then
	echo "[ERROR] timeoutThreshold variable must be greater than or equal to 0"
	echo "[TARDIS LAUNCHER] ENDING at $(date)"
	exit 1
fi
timeoutTime="$((timeoutThreshold+globalTime))m"
echo "timeoutTime: $timeoutTime"

echo "[TARDIS LAUNCHER] Choose the benchmarks to run:"
echo "[TARDIS LAUNCHER] Type the number corresponding to one or more benchmarks (separated by space) and press enter"
echo " ------------------------ "
echo "|  1)  ALL BENCHMARKS    |"
echo "|  2)  AUTHZFORCE        |"
echo "|  3)  BCEL              |"
echo "|  4)  DUBBO             |"
echo "|  5)  FASTJSON          |"
echo "|  6)  FESCAR            |"
echo "|  7)  GSON              |"
echo "|  8)  GUAVA             |"
echo "|  9)  IMAGE             |"
echo "|  10) JSOUP             |"
echo "|  11) JXPATH            |"
echo "|  12) LA4J              |"
echo "|  13) OKHTTP            |"
echo "|  14) OKIO              |"
echo "|  15) PDFBOX            |"
echo "|  16) RE2J              |"
echo "|  17) SPOON             |"
echo "|  18) WEBMAGIC          |"
echo "|  19) ZXING             |"
echo "|  20) WEKA              |"
echo "|  21) FASTJSON 9th      |"
echo "|  22) GUAVA 9th         |"
echo "|  23) SINERGY           |"
echo " ------------------------ "
read input
input_array=($input)

dt=$(date +%Y_%m_%d_%H_%M_%S)
export dt
mkdir -p $LOG_PATH/$dt

#copy the file containing the paths for the coverage tool and insert the specific paths in the copied file
#Nothing
#paths manipulation to make them work with "sed s"
TARDIS_HOME_PATH_ESC=$(echo $TARDIS_HOME_PATH | sed 's_/_\\/_g')
Z3_PATH_ESC=$(echo $Z3_PATH | sed 's_/_\\/_g')
REPO_HOME_PATH_ESC=$(echo $REPO_HOME_PATH | sed 's_/_\\/_g')

#copy the file containing the paths for the coverage tool and insert the specific paths in the copied file
cp -f benchmarksListBenatti.list CovarageTool/benchmarksRepoPath.list
sed -i "s/REPOSITORYHOMEPATH/$REPO_HOME_PATH_ESC/g" CovarageTool/benchmarksRepoPath.list
sed -i "s/TARDISHOMEPATH/$TARDIS_HOME_PATH_ESC/g" CovarageTool/benchmarksRepoPath.list

#compile the Tardis logs analysis script
javac CalculateResults.java && echo "[TARDIS LAUNCHER] CalculateResults.java compiled" || echo "[TARDIS LAUNCHER] Failed"

#function to calculate the coverage of the seed tests only
#parameters: $TMPDIR $seedTestNum $BENCHMARK $LOG_PATH/$dt/AUTHZFORCE $globalTime
seed_test_cov () {
	#list of subfolders from deepest to shallowest
	testDirs="$(find $1/test -depth -type d)"
	#list of subfolders transformed into an array
	arrTestDirs=($testDirs)
	#create directory $TMPDIR/seedTest/deeper subdirectory minus everything before the test/ directory
	testSubPath=$(echo ${arrTestDirs[0]} | sed 's/.*test\///g')
	mkdir -p $1/seedTest/$testSubPath
	for i in `seq 0 $2`; do
		test -f $1/test/$testSubPath/*_${i}_Test.java && cp $1/test/$testSubPath/*_${i}_Test.java $1/seedTest/$testSubPath
	done
	java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" SEEDTARDIS $3 $4 1 $5 --only-compute-metrics $1/seedTest
}

#if set, run system resources logging script
if [ $systemlogging == "1" ]; then
	bash SystemLoadLogging.sh &
	SystemLoadLogging_PID=$!
fi

#Authzforce
if [[ " ${input_array[@]} " =~ " 2 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/AUTHZFORCE
	#copy runtool to the LOG_PATH folder to make the coverage tool happy
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/AUTHZFORCE

	for BENCHMARK in AUTHZFORCE-1 AUTHZFORCE-11 AUTHZFORCE-27 AUTHZFORCE-32 AUTHZFORCE-33 AUTHZFORCE-48
	do
		echo "[TARDIS LAUNCHER] Run benchmark AUTHZFORCE -- Target class: $BENCHMARK"
		#set the Tardis run files with the current target class
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunAuthzforce1.java
		#compile the run files
		bash CompileAndMove.sh
		#run Tardis
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/core-release-13.3.0/pdp-engine/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/core-release-13.3.0/dependencies/* settings.RunAuthzforce1 |& tee $LOG_PATH/$dt/AUTHZFORCE/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		#run the Tardis log analysis script and extract the number of seed test (to calculate the coverage of the seed tests only)
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/AUTHZFORCE/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Authzforce$BENCHMARK)"
		#extract the tardis-tmp folder
		TMPDIR=$(ls -td $REPO_HOME_PATH/core-release-13.3.0/tardis-tmp/* | head -1)
		#if set, perform the coverage tool for the seed tests only
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/AUTHZFORCE $globalTime
		fi
		#Perform Jacoco
		source JacoLaunch.sh
		#perform the coverage tool for all tests
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/AUTHZFORCE 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
	mv $REPO_HOME_PATH/report $REPO_HOME_PATH/core-release-13.3.0/
fi

#Bcel
if [[ " ${input_array[@]} " =~ " 3 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/BCEL
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/BCEL
	for BENCHMARK in BCEL-1 BCEL-3 BCEL-4 BCEL-6
	do
		echo "[TARDIS LAUNCHER] Run benchmark BCEL -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunBcel.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/bcel-6.0-src/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunBcel |& tee $LOG_PATH/$dt/BCEL/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/BCEL/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Bcel$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/bcel-6.0-src/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/BCEL $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/BCEL 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Dubbo
if [[ " ${input_array[@]} " =~ " 4 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/DUBBO
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/DUBBO
	for BENCHMARK in DUBBO-3 DUBBO-4 DUBBO-5 DUBBO-7 DUBBO-8 DUBBO-9
	do
		echo "[TARDIS LAUNCHER] Run benchmark DUBBO -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunDubbo.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/dubbo/dubbo-common/target/classes:$REPO_HOME_PATH/dubbo/dubbo-cluster/target/classes:$REPO_HOME_PATH/dubbo/dubbo-container/dubbo-container-api/target/classes:$REPO_HOME_PATH/dubbo/dubbo-container/dubbo-container-log4j/target/classes:$REPO_HOME_PATH/dubbo/dubbo-container/dubbo-container-logback/target/classes:$REPO_HOME_PATH/dubbo/dubbo-container/dubbo-container-spring/target/classes:$REPO_HOME_PATH/dubbo/dubbo-demo/dubbo-demo-api/target/classes:$REPO_HOME_PATH/dubbo/dubbo-demo/dubbo-demo-consumer/target/classes:$REPO_HOME_PATH/dubbo/dubbo-demo/dubbo-demo-provider/target/classes:$REPO_HOME_PATH/dubbo/dubbo-filter/dubbo-filter-cache/target/classes:$REPO_HOME_PATH/dubbo/dubbo-filter/dubbo-filter-validation/target/classes:$REPO_HOME_PATH/dubbo/dubbo-monitor/dubbo-monitor-api/target/classes:$REPO_HOME_PATH/dubbo/dubbo-monitor/dubbo-monitor-default/target/classes:$REPO_HOME_PATH/dubbo/dubbo-plugin/dubbo-qos/target/classes:$REPO_HOME_PATH/dubbo/dubbo-registry/dubbo-registry-api/target/classes:$REPO_HOME_PATH/dubbo/dubbo-registry/dubbo-registry-default/target/classes:$REPO_HOME_PATH/dubbo/dubbo-registry/dubbo-registry-multicast/target/classes:$REPO_HOME_PATH/dubbo/dubbo-registry/dubbo-registry-redis/target/classes:$REPO_HOME_PATH/dubbo/dubbo-registry/dubbo-registry-zookeeper/target/classes:$REPO_HOME_PATH/dubbo/hessian-lite/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunDubbo |& tee $LOG_PATH/$dt/DUBBO/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/DUBBO/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Dubbo$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/dubbo/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/DUBBO $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/DUBBO 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Fastjson
if [[ " ${input_array[@]} " =~ " 5 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/FASTJSON
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/FASTJSON
	for BENCHMARK in FASTJSON-1 FASTJSON-2 FASTJSON-3 FASTJSON-4 FASTJSON-5 FASTJSON-6 FASTJSON-7 FASTJSON-8 FASTJSON-9 FASTJSON-10
	do
		echo "$BENCHMARK"
		echo "[TARDIS LAUNCHER] Run benchmark FASTJSON -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunFastjson.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/fastjson/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunFastjson |& tee $LOG_PATH/$dt/FASTJSON/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/FASTJSON/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Fastjson$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/fastjson/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/FASTJSON $globalTime
		fi
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/FASTJSON 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Fescar
if [[ " ${input_array[@]} " =~ " 6 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/FESCAR
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/FESCAR
	for BENCHMARK in FESCAR-18 FESCAR-23 FESCAR-36 FESCAR-2 FESCAR-9 FESCAR-10 FESCAR-13 FESCAR-17 FESCAR-28 FESCAR-33 FESCAR-34
	do
		echo "[TARDIS LAUNCHER] Run benchmark FESCAR -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunFescar.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/fescar/core/target/classes:$REPO_HOME_PATH/fescar/common/target/classes:$REPO_HOME_PATH/fescar/config/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/fescar/dependencies/* settings.RunFescar |& tee $LOG_PATH/$dt/FESCAR/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/FESCAR/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Fescar$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/fescar/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/FESCAR $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/FESCAR 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Gson
if [[ " ${input_array[@]} " =~ " 7 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/GSON
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/GSON
	for BENCHMARK in GSON-1 GSON-2 GSON-3 GSON-4 GSON-5 GSON-6 GSON-7 GSON-8 GSON-9 GSON-10
	do
		echo "[TARDIS LAUNCHER] Run benchmark GSON -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunGson.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/gson/gson/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunGson |& tee $LOG_PATH/$dt/GSON/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/GSON/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Gson$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/gson/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/GSON $globalTime
		fi
		 #Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/GSON 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Guava
if [[ " ${input_array[@]} " =~ " 8 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/GUAVA
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/GUAVA
	for BENCHMARK in GUAVA-90 GUAVA-128 GUAVA-159 GUAVA-169 GUAVA-181 GUAVA-184 GUAVA-196 GUAVA-212 GUAVA-224
	do
		echo "[TARDIS LAUNCHER] Run benchmark GUAVA -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunGuava.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/guava/guava/target/classes:$REPO_HOME_PATH/guava/guava/target/guava-28.2-jre.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunGuava |& tee $LOG_PATH/$dt/GUAVA/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/GUAVA/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Guava$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/guava/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/GUAVA $globalTime
		fi
                #Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/GUAVA 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Image
if [[ " ${input_array[@]} " =~ " 9 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/IMAGE
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/IMAGE
	for BENCHMARK in IMAGE-2 IMAGE-3 IMAGE-4
	do
		echo "[TARDIS LAUNCHER] Run benchmark IMAGE -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunImage.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/commons-imaging/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunImage |& tee $LOG_PATH/$dt/IMAGE/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/IMAGE/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Image$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/commons-imaging/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/IMAGE $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/IMAGE 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Jsoup
if [[ " ${input_array[@]} " =~ " 10 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/JSOUP
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/JSOUP
	for BENCHMARK in JSOUP-1 JSOUP-2 JSOUP-3 JSOUP-4 JSOUP-5
	do
		echo "[TARDIS LAUNCHER] Run benchmark JSOUP -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunJsoup.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/jsoup/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunJsoup |& tee $LOG_PATH/$dt/JSOUP/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/JSOUP/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Jsoup$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/jsoup/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/JSOUP $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/JSOUP 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Jxpath
if [[ " ${input_array[@]} " =~ " 11 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/JXPATH
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/JXPATH
	for BENCHMARK in JXPATH-1 JXPATH-2 JXPATH-3 JXPATH-4 JXPATH-5 JXPATH-7 JXPATH-9 JXPATH-10
	do
		echo "[TARDIS LAUNCHER] Run benchmark JXPATH -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunJxpath.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/commons-jxpath-1.3-src/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunJxpath |& tee $LOG_PATH/$dt/JXPATH/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/JXPATH/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Jxpath$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/commons-jxpath-1.3-src/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/JXPATH $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/JXPATH 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#La4j
if [[ " ${input_array[@]} " =~ " 12 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/LA4J
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/LA4J
	for BENCHMARK in LA4J-1 LA4J-2 LA4J-3 LA4J-4 LA4J-5 LA4J-6 LA4J-7 LA4J-8 LA4J-9 LA4J-10
	do
		echo "[TARDIS LAUNCHER] Run benchmark LA4J -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunLa4j.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/la4j-0.6.0/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunLa4j |& tee $LOG_PATH/$dt/LA4J/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/LA4J/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv La4j$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/la4j-0.6.0/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/LA4J $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/LA4J 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Okhttp
if [[ " ${input_array[@]} " =~ " 13 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/OKHTTP
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/OKHTTP
	for BENCHMARK in OKHTTP-1 OKHTTP-3 OKHTTP-4 OKHTTP-5 OKHTTP-6 OKHTTP-7 OKHTTP-8
	do
		echo "[TARDIS LAUNCHER] Run benchmark OKHTTP -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunOkhttp.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/okhttp/okhttp/target/classes:$REPO_HOME_PATH/okhttp/dependencies/okio-1.11.0.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunOkhttp |& tee $LOG_PATH/$dt/OKHTTP/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/OKHTTP/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Okhttp$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/okhttp/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/OKHTTP $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/OKHTTP 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Okio
if [[ " ${input_array[@]} " =~ " 14 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/OKIO
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/OKIO
	for BENCHMARK in OKIO-1 OKIO-4 OKIO-5 OKIO-6 OKIO-7 OKIO-8 OKIO-9 OKIO-10
	do
		echo "[TARDIS LAUNCHER] Run benchmark OKIO -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunOkio.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/okio/okio/target/classes:$REPO_HOME_PATH/okio/samples/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunOkio |& tee $LOG_PATH/$dt/OKIO/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/OKIO/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Okio$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/okio/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/OKIO $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/OKIO 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Pdfbox
if [[ " ${input_array[@]} " =~ " 15 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/PDFBOX
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/PDFBOX
	for BENCHMARK in PDFBOX-22 PDFBOX-26 PDFBOX-40 PDFBOX-62 PDFBOX-83 PDFBOX-91 PDFBOX-117 PDFBOX-127 PDFBOX-157 PDFBOX-214 PDFBOX-220 PDFBOX-229 PDFBOX-234 PDFBOX-235 PDFBOX-265 PDFBOX-278
	do
		echo "[TARDIS LAUNCHER] Run benchmark PDFBOX -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunPdfbox.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/pdfbox/pdfbox/target/classes:$REPO_HOME_PATH/pdfbox/pdfbox/target/pdfbox-2.0.18.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/pdfbox/dependencies/* settings.RunPdfbox |& tee $LOG_PATH/$dt/PDFBOX/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/PDFBOX/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Pdfbox$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/pdfbox/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/PDFBOX $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/PDFBOX 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Re2j
if [[ " ${input_array[@]} " =~ " 16 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/RE2J
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/RE2J
	for BENCHMARK in RE2J-1 RE2J-2 RE2J-3 RE2J-4 RE2J-5 RE2J-6 RE2J-7 RE2J-8
	do
		echo "[TARDIS LAUNCHER] Run benchmark RE2J -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunRe2j.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/re2j/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunRe2j |& tee $LOG_PATH/$dt/RE2J/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/RE2J/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Re2j$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/re2j/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/RE2J $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/RE2J 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Spoon
if [[ " ${input_array[@]} " =~ " 17 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/SPOON
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/SPOON
	for BENCHMARK in SPOON-105 SPOON-25 SPOON-253 SPOON-65
	do
		echo "[TARDIS LAUNCHER] Run benchmark SPOON -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunSpoon.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/spoon/target/classes:$REPO_HOME_PATH/spoon/target/spoon-core-7.2.0.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/spoon/dependencies/* settings.RunSpoon |& tee $LOG_PATH/$dt/SPOON/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/SPOON/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Spoon$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/spoon/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/SPOON $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/SPOON 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
	#Moving report folder after execution
	mv $REPO_HOME_PATH/report $REPO_HOME_PATH/Results/reportSpoon
fi

#Webmagic
if [[ " ${input_array[@]} " =~ " 18 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/WEBMAGIC
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/WEBMAGIC
	for BENCHMARK in WEBMAGIC-1 WEBMAGIC-5
	do
		echo "[TARDIS LAUNCHER] Run benchmark WEBMAGIC -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunWebmagic1_5.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/webmagic/webmagic-extension/target/classes:$REPO_HOME_PATH/webmagic/webmagic-core/target/classes:$REPO_HOME_PATH/webmagic/webmagic-samples/target/classes:$REPO_HOME_PATH/webmagic/webmagic-saxon/target/classes:$REPO_HOME_PATH/webmagic/webmagic-scripts/target/classes:$REPO_HOME_PATH/webmagic/webmagic-selenium/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunWebmagic1_5 |& tee $LOG_PATH/$dt/WEBMAGIC/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/WEBMAGIC/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Webmagic$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/webmagic/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/WEBMAGIC $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/WEBMAGIC 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
	for BENCHMARK in WEBMAGIC-2 WEBMAGIC-3 WEBMAGIC-4
	do
		echo "[TARDIS LAUNCHER] Run benchmark WEBMAGIC -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunWebmagic2_3_4.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/webmagic/webmagic-extension/target/classes:$REPO_HOME_PATH/webmagic/webmagic-core/target/classes:$REPO_HOME_PATH/webmagic/webmagic-samples/target/classes:$REPO_HOME_PATH/webmagic/webmagic-saxon/target/classes:$REPO_HOME_PATH/webmagic/webmagic-scripts/target/classes:$REPO_HOME_PATH/webmagic/webmagic-selenium/target/classes:$REPO_HOME_PATH/webmagic/dependencies/jsoup-1.10.3.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunWebmagic2_3_4 |& tee $LOG_PATH/$dt/WEBMAGIC/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/WEBMAGIC/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Webmagic$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/webmagic/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/WEBMAGIC $globalTime
		fi
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/WEBMAGIC 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Zxing
if [[ " ${input_array[@]} " =~ " 19 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/ZXING
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/ZXING
	for BENCHMARK in ZXING-1 ZXING-2 ZXING-3 ZXING-5 ZXING-7 ZXING-8 ZXING-9 ZXING-10
	do
		echo "[TARDIS LAUNCHER] Run benchmark ZXING -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunZxing.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/zxing/core/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunZxing |& tee $LOG_PATH/$dt/ZXING/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/ZXING/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Zxing$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/zxing/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/ZXING $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/ZXING 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Weka
if [[ " ${input_array[@]} " =~ " 20 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/WEKA
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/WEKA
	for BENCHMARK in WEKA-673 WEKA-460 WEKA-983 WEKA-741 WEKA-53 WEKA-303 WEKA-1127 WEKA-576 WEKA-7 WEKA-592 WEKA-871 WEKA-79 WEKA-763 WEKA-1088 WEKA-1006 WEKA-563 WEKA-151 WEKA-577
	do
		echo "[TARDIS LAUNCHER] Run benchmark WEKA -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunWeka.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/weka/dist/weka-stable-3.8.5-SNAPSHOT.jar:$REPO_HOME_PATH/weka/dist:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunWeka |& tee $LOG_PATH/$dt/WEKA/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/WEKA/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Weka$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/weka/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/WEKA $globalTime
		fi
		#Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/WEKA 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Fastjson9th
if [[ " ${input_array[@]} " =~ " 21 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/FASTJSON9TH
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/FASTJSON9TH
	for BENCHMARK in FASTJSON-999 FASTJSON-11 FASTJSON-17 FASTJSON-29 FASTJSON-36 FASTJSON-45 FASTJSON-49 FASTJSON-57 FASTJSON-65 FASTJSON-72 FASTJSON-78 FASTJSON-79 FASTJSON-86 FASTJSON-94 FASTJSON-99 FASTJSON-100 FASTJSON-108 FASTJSON-113 FASTJSON-120
	do
		echo "[TARDIS LAUNCHER] Run benchmark FASTJSON9TH -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunFastjson9th.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/fastjson9th/target/fastjson-1.2.63_preview_01.jar:$REPO_HOME_PATH/fastjson9th/target:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunFastjson9th |& tee $LOG_PATH/$dt/FASTJSON9TH/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/FASTJSON9TH/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Fastjson9th$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/fastjson9th/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/FASTJSON9TH $globalTime
		fi
                #Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/FASTJSON9TH 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Guava9th
if [[ " ${input_array[@]} " =~ " 22 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/GUAVA9TH
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/GUAVA9TH
	for BENCHMARK in GUAVA-71 GUAVA-273 GUAVA-11 GUAVA-999 GUAVA-998 GUAVA-200 GUAVA-254 GUAVA-192 GUAVA-96 GUAVA-267 GUAVA-232 GUAVA-227 GUAVA-156 GUAVA-118 GUAVA-61 GUAVA-199 GUAVA-226 GUAVA-213 GUAVA-148
	do
		echo "[TARDIS LAUNCHER] Run benchmark GUAVA9TH -- Target class: $BENCHMARK"
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" RunFiles/RunGuava9th.java
		bash CompileAndMove.sh
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/guava9th/guava/target/guava-29.0-jre.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/failureaccess-1.0.1.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/checker-qual-2.11.1.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/error_prone_annotations-2.3.4.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/srczip-999.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/j2objc-annotations-1.3.jar:$REPO_HOME_PATH/guava9th/guava/target/dependency/jsr305-3.0.2.jar:$REPO_HOME_PATH/guava9th/guava/target:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.0.6-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.RunGuava9th |& tee $LOG_PATH/$dt/GUAVA9TH/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/GUAVA9TH/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Guava9th$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/guava9th/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/GUAVA9TH $globalTime
		fi
                #Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/GUAVA9TH 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi

#Sinergy
if [[ " ${input_array[@]} " =~ " 23 " ]] || [[ " ${input_array[@]} " =~ " 1 " ]]; then
	mkdir $LOG_PATH/$dt/SINERGY
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/SINERGY
	
	for BENCHMARK in SINERGY-1
	do
		echo "[TARDIS LAUNCHER] Run benchmark SINERGY -- Target class: $BENCHMARK"
		#sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" tardis-src/sinergy/RunEasy4TardisButHard4Evo.java
		bash CompileAndMove.sh
		
		cd tardis-src
		
		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/tardis-src/sinergy:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:. sinergy.RunEasy4TardisButHard4Evo |& tee $LOG_PATH/$dt/SINERGY/tardisLog$BENCHMARK.txt
		
		cd ..
		
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
		seedTestNum="$(java CalculateResults $LOG_PATH/$dt/SINERGY/tardisLog$BENCHMARK.txt $LOG_PATH/$dt/Results.csv Sinergy$BENCHMARK)"
		TMPDIR=$(ls -td $REPO_HOME_PATH/tardis-src/sinergy/tardis-tmp/* | head -1)
		if [ $doubleCoverageCalculation == "1" ]; then
			seed_test_cov $TMPDIR "$(($seedTestNum-1))" $BENCHMARK $LOG_PATH/$dt/SINERGY $globalTime
		fi
                #Perform Jacoco
                source JacoLaunch.sh
		java -ea -Dsbst.benchmark.jacoco="$REPO_HOME_PATH/CovarageTool/jacocoagent.jar" -Dsbst.benchmark.java="java" -Dsbst.benchmark.javac="javac" -Dsbst.benchmark.config="$REPO_HOME_PATH/CovarageTool/benchmarksRepoPath.list" -Dsbst.benchmark.junit="$REPO_HOME_PATH/CovarageTool/junit-4.12.jar" -Dsbst.benchmark.junit.dependency="$REPO_HOME_PATH/CovarageTool/hamcrest-core-1.3.jar" -Dsbst.benchmark.pitest="$REPO_HOME_PATH/CovarageTool/pitest-1.1.11.jar:$REPO_HOME_PATH/CovarageTool/pitest-command-line-1.1.11.jar" -jar "$REPO_HOME_PATH/CovarageTool/benchmarktool-1.0.0-shaded.jar" TARDIS $BENCHMARK $LOG_PATH/$dt/SINERGY 1 $globalTime --only-compute-metrics $TMPDIR/test
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done
fi




#if set, stop system resources logging script
if [ $systemlogging == "1" ]; then
	kill $SystemLoadLogging_PID
fi

#Moving report folder after execution
#mv $REPO_HOME_PATH/report $REPO_HOME_PATH/Results/reportSpoon

echo "[TARDIS LAUNCHER] ENDING at $(date)"
