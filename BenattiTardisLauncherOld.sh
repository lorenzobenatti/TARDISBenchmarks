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
TARDIS_HOME_PATH=/dev/hd2/tardisPiacente
Z3_PATH=/dev/hd2/usr/opt/z3/z3-4.8.9-x64-ubuntu-16.04/bin/z3
REPO_HOME_PATH=/dev/hd2/TARDISBenchmarks
GRADLE_REPO_PATH=/dev/hd2/usr/.gradle
LOG_PATH=/dev/hd2/tardisBenattiScripts/tardisLogs
TOOLSJAR_PATH=/dev/hd2/usr/lib/jvm/jdk1.8.0_261/lib
# -------------------------------------------------------------------------------

globalTime=15

# kill all processes made by benatti which aren't system processes, which isn't the current process, which isn't a bash process and which isn't one of the processes which must be still running for xrdp

username="benatti"

# Get the PID of the current script
current_pid="$$"

# Get the PIDs of the user's processes (excluding the current process and system processes)
pids=$(pgrep -U "$username" -d ',' -P 1)

# Exclude specific processes and their sub-processes
exclude_processes=(
    gnome-keyring-daemon
    pulseaudio
    systemd
    vmtoolsd
    Xorg
    xrdp-chansrv
)

# Kill each process individually, excluding the specified processes and their sub-processes
for pid in $(echo "$pids" | tr ',' ' '); do
    if [ "$pid" != "$current_pid" ] && [ ! -f "/proc/$pid/cmdline" ] && ! ps -o args= -p "$pid" | grep -qE "$(IFS="|"; echo "${exclude_processes[*]}")"; then
        kill "$pid"
    fi
done

# PASS 2 ARGUMENTS: 
# - THE EVOSUITE MULTISEARCH (true or false)
# - THE EXPERIMENT NUMBER (IT CAN BE 1 TO RUN ALL EXPERIMENTS)

# Check if three arguments were provided
if [ $# -ne 2 ]; then
  echo "[ERROR] Usage: bash BenattiTardisLauncher.sh <true|false> <number>"
  echo "<true|false> is evosuiteMultiSearch"
  echo "<number> is the experiment number chosen from the list below"
  
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
  echo "|  13) OKHTTP (err)      |"
  echo "|  14) OKIO              |"
  echo "|  15) PDFBOX            |"
  echo "|  16) RE2J              |"
  echo "|  17) SPOON             |"
  echo "|  18) WEBMAGIC          |"
  echo "|  19) ZXING (err)       |"
  echo "|  20) WEKA              |"
  echo "|  21) FASTJSON9th       |"
  echo "|  22) GUAVA9th          |"
  echo "|  23) MIPC (no rpt)     |"
  echo " ------------------------ "
  
  exit 1
fi

# Get the first argument
evosuiteMultiSearch=$1

# Check if the argument is valid
if [ "$evosuiteMultiSearch" != "true" ] && [ "$evosuiteMultiSearch" != "false" ]; then
  echo "[ERROR] Invalid argument! It must be 'true' or 'false'."
  exit 1
fi

# Get the second argument and validate it as a number greater than 0
input_number=$2

# Check if the number is a valid positive integer
if ! [[ $input_number =~ ^[1-9][0-9]*$ ]]; then
  echo "[ERROR] Invalid number! It must be a positive integer greater than 0."
  exit 1
fi


# -------------------------------------------------------------------------------
# Editable variables:

# Set javaMem variable with xmx and/or xms value (-Xms16G -Xmx16G)
javaMem="-Xms16G -Xmx16G -Xss1G" # the default was 16G with also -Xss1G
# Set sizeThreshold variable to choose the maximum size (MB) of tardis-tmp 
# folders. Tmp folders will be deleted if the size is greater than sizeThreshold.
sizeThreshold=1000
# Set timeoutThreshold variable to decide after how many minutes kill the 
# execution if still running after $globalTime minutes
timeoutThreshold=1
# Set systemlogging to 1 to save system load data in systemLog.csv file.
#systemlogging=1
# -------------------------------------------------------------------------------

if [ $timeoutThreshold -lt 0 ]; then
	echo "[ERROR] timeoutThreshold variable must be greater than or equal to 0"
	echo "[TARDIS LAUNCHER] ENDING at $(date)"
	exit 1
fi
timeoutTime="$((timeoutThreshold+globalTime))m"
echo "timeoutTime: $timeoutTime"

echo "[TARDIS LAUNCHER] The chosen experiment number is $input_number"

dt=$(date +%Y_%m_%d_%H_%M_%S)
mkdir -p $LOG_PATH/$dt

#paths manipulation to make them work with "sed s"
TARDIS_HOME_PATH_ESC=$(echo $TARDIS_HOME_PATH | sed 's_/_\\/_g')
Z3_PATH_ESC=$(echo $Z3_PATH | sed 's_/_\\/_g')
REPO_HOME_PATH_ESC=$(echo $REPO_HOME_PATH | sed 's_/_\\/_g')

#copy the file containing the paths for the coverage tool and insert the specific paths in the copied file
cp -f CovarageTool/benchmarks.list CovarageTool/benchmarksRepoPath.list
sed -i "s/REPOSITORYHOMEPATH/$REPO_HOME_PATH_ESC/g" CovarageTool/benchmarksRepoPath.list
sed -i "s/TARDISHOMEPATH/$TARDIS_HOME_PATH_ESC/g" CovarageTool/benchmarksRepoPath.list

#if set, run system resources logging script
#if [ $systemlogging == "1" ]; then
#	bash SystemLoadLogging.sh &
#	SystemLoadLogging_PID=$!
#fi

#Authzforce
if [ "$input_number" -eq 2 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for AUTHZFORCE."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="AUTHZFORCE"
		#experiment folder name
		string1="core-release-13.3.0"
		#name of the .java file
		run_file_name="RunAuthzforce1"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("AUTHZFORCE-1" "AUTHZFORCE-11" "AUTHZFORCE-27" "AUTHZFORCE-32" "AUTHZFORCE-33" "AUTHZFORCE-48")
		benchmarks_array=("AUTHZFORCE-33")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file
		
		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"
			
			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file
			
			#compile the run files
			bash CompileAndMove.sh
			
			#run Tardis
			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/pdp-engine/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/core-release-13.3.0/dependencies/* settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
			
			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Bcel
if [ "$input_number" -eq 3 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for BCEL."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="BCEL"
		#experiment folder name
		string1="bcel-6.0-src"
		#name of the .java file
		run_file_name="RunBcel"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("BCEL-1" "BCEL-2" "BCEL-3" "BCEL-4" "BCEL-5" "BCEL-6" "BCEL-7")
		benchmarks_array=("BCEL-7")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file
		
		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file
			
			#compile the run files
			bash CompileAndMove.sh

			#run Tardis
			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
			
			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Dubbo
if [ "$input_number" -eq 4 ]; then #|| [ "$input_number" -eq 1 ]
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="DUBBO"
		#experiment folder name
		string1="dubbo"
		#name of the .java file
		run_file_name="RunDubbo"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("DUBBO-2" "DUBBO-3" "DUBBO-4" "DUBBO-5" "DUBBO-6" "DUBBO-7" "DUBBO-8" "DUBBO-9" "DUBBO-10")
        benchmarks_array=()
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file
		
		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/dubbo-common/target/classes:$REPO_HOME_PATH/$string1/dubbo-cluster/target/classes:$REPO_HOME_PATH/$string1/dubbo-container/dubbo-container-api/target/classes:$REPO_HOME_PATH/$string1/dubbo-container/dubbo-container-log4j/target/classes:$REPO_HOME_PATH/$string1/dubbo-container/dubbo-container-logback/target/classes:$REPO_HOME_PATH/$string1/dubbo-container/dubbo-container-spring/target/classes:$REPO_HOME_PATH/$string1/dubbo-demo/dubbo-demo-api/target/classes:$REPO_HOME_PATH/$string1/dubbo-demo/dubbo-demo-consumer/target/classes:$REPO_HOME_PATH/$string1/dubbo-demo/dubbo-demo-provider/target/classes:$REPO_HOME_PATH/$string1/dubbo-filter/dubbo-filter-cache/target/classes:$REPO_HOME_PATH/$string1/dubbo-filter/dubbo-filter-validation/target/classes:$REPO_HOME_PATH/$string1/dubbo-monitor/dubbo-monitor-api/target/classes:$REPO_HOME_PATH/$string1/dubbo-monitor/dubbo-monitor-default/target/classes:$REPO_HOME_PATH/$string1/dubbo-plugin/dubbo-qos/target/classes:$REPO_HOME_PATH/$string1/dubbo-registry/dubbo-registry-api/target/classes:$REPO_HOME_PATH/$string1/dubbo-registry/dubbo-registry-default/target/classes:$REPO_HOME_PATH/$string1/dubbo-registry/dubbo-registry-multicast/target/classes:$REPO_HOME_PATH/$string1/dubbo-registry/dubbo-registry-redis/target/classes:$REPO_HOME_PATH/$string1/dubbo-registry/dubbo-registry-zookeeper/target/classes:$REPO_HOME_PATH/$string1/hessian-lite/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Fastjson
if [ "$input_number" -eq 5 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="FASTJSON"
		#experiment folder name
		string1="fastjson"
		#name of the .java file
		run_file_name="RunFastjson"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("FASTJSON-2" "FASTJSON-3" "FASTJSON-4" "FASTJSON-5" "FASTJSON-6" "FASTJSON-7" "FASTJSON-8" "FASTJSON-9" "FASTJSON-10")
		benchmarks_array=()
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
			
			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Fescar
if [ "$input_number" -eq 6 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for FESCAR."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="FESCAR"
		#experiment folder name
		string1="fescar"
		#name of the .java file
		run_file_name="RunFescar"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("FESCAR-18" "FESCAR-23" "FESCAR-36" "FESCAR-2" "FESCAR-5" "FESCAR-9" "FESCAR-10" "FESCAR-13" "FESCAR-17" "FESCAR-28" "FESCAR-33" "FESCAR-34")
		benchmarks_array=("FESCAR-10")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/core/target/classes:$REPO_HOME_PATH/$string1/common/target/classes:$REPO_HOME_PATH/$string1/config/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/fescar/dependencies/* settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Gson
if [ "$input_number" -eq 7 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="GSON"
		#experiment folder name
		string1="gson"
		#name of the .java file
		run_file_name="RunGson"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("GSON-1" "GSON-2" "GSON-3" "GSON-4" "GSON-5" "GSON-6" "GSON-7" "GSON-8" "GSON-9" "GSON-10")
		benchmarks_array=("GSON-1" "GSON-10")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/gson/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Guava
if [ "$input_number" -eq 8 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="GUAVA"
		#experiment folder name
		string1="guava"
		#name of the .java file
		run_file_name="RunGuava"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("GUAVA-90" "GUAVA-128" "GUAVA-159" "GUAVA-169" "GUAVA-181" "GUAVA-184" "GUAVA-196" "GUAVA-212" "GUAVA-224")
		benchmarks_array=("GUAVA-90" "GUAVA-196")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/guava/target/classes:$REPO_HOME_PATH/$string1/guava/target/guava-28.2-jre.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Image
if [ "$input_number" -eq 9 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="IMAGE"
		#experiment folder name
		string1="commons-imaging"
		#name of the .java file
		run_file_name="RunImage"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("IMAGE-2" "IMAGE-3" "IMAGE-4")
		benchmarks_array=()
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Jsoup
if [ "$input_number" -eq 10 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for JSOUP."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="JSOUP"
		#experiment folder name
		string1="jsoup"
		#name of the .java file
		run_file_name="RunJsoup"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("JSOUP-1" "JSOUP-2" "JSOUP-3" "JSOUP-4" "JSOUP-5")
		benchmarks_array=()
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Jxpath
if [ "$input_number" -eq 11 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for JXPATH."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="JXPATH"
		#experiment folder name
		string1="commons-jxpath-1.3-src"
		#name of the .java file
		run_file_name="RunJxpath"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("JXPATH-1" "JXPATH-2" "JXPATH-3" "JXPATH-4" "JXPATH-5" "JXPATH-7" "JXPATH-8" "JXPATH-9" "JXPATH-10")
        benchmarks_array=("JXPATH-3" "JXPATH-4")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#La4j
if [ "$input_number" -eq 12 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="LA4J"
		#experiment folder name
		string1="la4j-0.6.0"
		#name of the .java file
		run_file_name="RunLa4j"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		#benchmarks_array=("LA4J-1" "LA4J-2" "LA4J-3" "LA4J-4" "LA4J-6" "LA4J-7" "LA4J-9" "LA4J-10")
		benchmarks_array=("LA4J-9")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
			
			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Okhttp !!! BROKEN PROJECT BUILD !!!
if [ "$input_number" -eq 13 ] || [ "$input_number" -eq 1 ]; then
	echo "[TARDIS LAUNCHER] Okhttp has a broken project build, nothing will be executed."
	: '
	#experiment
    project_name="OKHTTP"
	#experiment folder name
	string1="okhttp"
	#name of the .java file
	run_file_name="RunOkhttp"
	run_file="RunFiles/$run_file_name.java"
	#array containing the benchmarks
	benchmarks_array=("OKHTTP-1" "OKHTTP-2" "OKHTTP-3" "OKHTTP-4" "OKHTTP-5" "OKHTTP-6" "OKHTTP-7" "OKHTTP-8")
	#length
	number=${#benchmarks_array[@]}

	echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

	mkdir $LOG_PATH/$dt/$project_name
	#copy runtool to the LOG_PATH folder to make the coverage tool happy
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

	#set evosuiteMultiSearch
    sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file

	for BENCHMARK in "${benchmarks_array[@]}"; do
		echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

		#set the Tardis run files with the current target class
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

		#compile the run files
		bash CompileAndMove.sh

		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/okhttp/target/classes:$REPO_HOME_PATH/$string1/dependencies/okio-1.11.0.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

		#extract the tardis-tmp folder
		TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

        #Perform Jacoco
        echo "[TARDIS LAUNCHER] JACOCO"

        source JacoLaunch.sh
        
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done

	

    #number was already set before and its how many benchmarks were executed
    #string1 was already set too, as the experiment folder name
    string2="" #result name
    if [ "$evosuiteMultiSearch" = "true" ]; then
        string2="$project_name classifier"
    else
        string2="$project_name no multiSearch"
    fi

    cd /dev/hd2/tardisBenattiScripts

    echo "[TARDIS LAUNCHER] NewGenerateResult"

    source NewGenerateResult.sh

    cd "$REPO_HOME_PATH"
	'
fi

#Okio
if [ "$input_number" -eq 14 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for OKIO."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="OKIO"
		#experiment folder name
		string1="okio"
		#name of the .java file
		run_file_name="RunOkio"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("OKIO-1" "OKIO-4" "OKIO-5" "OKIO-6" "OKIO-7" "OKIO-8" "OKIO-9" "OKIO-10")
		#benchmarks_array=("OKIO-1")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/okio/target/classes:$REPO_HOME_PATH/$string1/samples/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Pdfbox
if [ "$input_number" -eq 15 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="PDFBOX"
		#experiment folder name
		string1="pdfbox"
		#name of the .java file
		run_file_name="RunPdfbox"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("PDFBOX-8" "PDFBOX-22" "PDFBOX-26" "PDFBOX-40" "PDFBOX-62" "PDFBOX-83" "PDFBOX-91" "PDFBOX-117" "PDFBOX-127" "PDFBOX-157" "PDFBOX-214" "PDFBOX-220" "PDFBOX-229" "PDFBOX-234" "PDFBOX-235" "PDFBOX-265" "PDFBOX-278" "PDFBOX-285")
		#benchmarks_array=("PDFBOX-214")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/pdfbox/target/classes:$REPO_HOME_PATH/$string1/pdfbox/target/pdfbox-2.0.18.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/$string1/dependencies/* settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Re2j
if [ "$input_number" -eq 16 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for RE2J."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="RE2J"
		#experiment folder name
		string1="re2j"
		#name of the .java file
		run_file_name="RunRe2j"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("RE2J-1" "RE2J-2" "RE2J-3" "RE2J-4" "RE2J-5" "RE2J-6" "RE2J-7" "RE2J-8")
		#benchmarks_array=("RE2J-8")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Spoon
if [ "$input_number" -eq 17 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for SPOON."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="SPOON"
		#experiment folder name
		string1="spoon"
		#name of the .java file
		run_file_name="RunSpoon"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("SPOON-105" "SPOON-25" "SPOON-253" "SPOON-65")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/classes:$REPO_HOME_PATH/$string1/target/spoon-core-7.2.0.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$REPO_HOME_PATH/$string1/dependencies/* settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Webmagic
if [ "$input_number" -eq 18 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for WEBMAGIC."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="WEBMAGIC"
		#experiment folder name
		string1="webmagic"
		#name of the .java file
		run_file_name1_5="RunWebmagic1_5"
		run_file1_5="RunFiles/$run_file_name1_5.java"
		run_file_name2_3_4="RunWebmagic2_3_4"
		run_file2_3_4="RunFiles/$run_file_name2_3_4.java"
		#array containing the benchmarks
		benchmarks_array1_5=("WEBMAGIC-1" "WEBMAGIC-5")
		#benchmarks_array1_5=()
		benchmarks_array2_3_4=("WEBMAGIC-2" "WEBMAGIC-3" "WEBMAGIC-4")
		#benchmarks_array2_3_4=("WEBMAGIC-2" "WEBMAGIC-4")
		#length
		number1_5=${#benchmarks_array1_5[@]}
		number2_3_4=${#benchmarks_array2_3_4[@]}
		number=$(($number1_5 + $number2_3_4))

		echo "[TARDIS LAUNCHER] project_name = $project_name, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file1_5
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file2_3_4
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file1_5
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file2_3_4

		for BENCHMARK in "${benchmarks_array1_5[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file1_5

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/webmagic-extension/target/classes:$REPO_HOME_PATH/$string1/webmagic-core/target/classes:$REPO_HOME_PATH/$string1/webmagic-samples/target/classes:$REPO_HOME_PATH/$string1/webmagic-saxon/target/classes:$REPO_HOME_PATH/$string1/webmagic-scripts/target/classes:$REPO_HOME_PATH/$string1/webmagic-selenium/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name1_5 |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		for BENCHMARK in "${benchmarks_array2_3_4[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file2_3_4

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/webmagic-extension/target/classes:$REPO_HOME_PATH/$string1/webmagic-core/target/classes:$REPO_HOME_PATH/$string1/webmagic-samples/target/classes:$REPO_HOME_PATH/$string1/webmagic-saxon/target/classes:$REPO_HOME_PATH/$string1/webmagic-scripts/target/classes:$REPO_HOME_PATH/$string1/webmagic-selenium/target/classes:$REPO_HOME_PATH/$string1/dependencies/jsoup-1.10.3.jar:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name2_3_4 |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Zxing !!! BROKEN PROJECT BUILD !!!
if [ "$input_number" -eq 19 ] || [ "$input_number" -eq 1 ]; then
	echo "[TARDIS LAUNCHER] Zxing has a broken project build, nothing will be executed."
	: '
	#experiment
    project_name="ZXING"
	#experiment folder name
	string1="zxing"
	#name of the .java file
	run_file_name="RunZxing"
	run_file="RunFiles/$run_file_name.java"
	#array containing the benchmarks
	benchmarks_array=("ZXING-1" "ZXING-2" "ZXING-3" "ZXING-4" "ZXING-5" "ZXING-7" "ZXING-8" "ZXING-9" "ZXING-10")
	#length
	number=${#benchmarks_array[@]}

	echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

	mkdir $LOG_PATH/$dt/$project_name
	#copy runtool to the LOG_PATH folder to make the coverage tool happy
	cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

	#set evosuiteMultiSearch
    sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file

	for BENCHMARK in "${benchmarks_array[@]}"; do
		echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

		#set the Tardis run files with the current target class
		sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

		#compile the run files
		bash CompileAndMove.sh

		timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/core/target/classes:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
		echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

		#extract the tardis-tmp folder
		TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

        #Perform Jacoco
        echo "[TARDIS LAUNCHER] JACOCO"

        source JacoLaunch.sh
        
		#Clean filesystem if necessary
		foldersize=$(du -sm $TMPDIR | cut -f1)
		if [[ $foldersize -gt $sizeThreshold ]]; then
			mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
		fi
	done

	

    #number was already set before and its how many benchmarks were executed
    #string1 was already set too, as the experiment folder name
    string2="" #result name
    if [ "$evosuiteMultiSearch" = "true" ]; then
        string2="$project_name classifier"
    else
        string2="$project_name no multiSearch"
    fi

    cd /dev/hd2/tardisBenattiScripts

    echo "[TARDIS LAUNCHER] NewGenerateResult"

    source NewGenerateResult.sh

    cd "$REPO_HOME_PATH"
	'
fi

#Weka
if [ "$input_number" -eq 20 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="WEKA"
		#experiment folder name
		string1="weka"
		#name of the .java file
		run_file_name="RunWeka"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("WEKA-673" "WEKA-460" "WEKA-983" "WEKA-741" "WEKA-53" "WEKA-303" "WEKA-7" "WEKA-592" "WEKA-871" "WEKA-79" "WEKA-763" "WEKA-1088" "WEKA-577")
		#benchmarks_array=("WEKA-983")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/dist/weka-stable-3.8.5-SNAPSHOT.jar:$REPO_HOME_PATH/$string1/dist:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#Fastjson9th
if [ "$input_number" -eq 21 ] || [ "$input_number" -eq 1 ]; then
	#echo "[TARDIS LAUNCHER] No benchmark for FASTJSON9TH."
	#: '
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="FASTJSON9TH"
		#experiment folder name
		string1="fastjson9th"
		#name of the .java file
		run_file_name="RunFastjson9th"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("FASTJSON-999" "FASTJSON-11" "FASTJSON-29" "FASTJSON-36" "FASTJSON-45" "FASTJSON-49" "FASTJSON-57" "FASTJSON-65" "FASTJSON-72" "FASTJSON-78" "FASTJSON-79" "FASTJSON-86" "FASTJSON-94" "FASTJSON-99" "FASTJSON-100" "FASTJSON-108" "FASTJSON-113" "FASTJSON-120")
		#benchmarks_array=("FASTJSON-113" "FASTJSON-120")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/target/fastjson-1.2.63_preview_01.jar:$REPO_HOME_PATH/$string1/target:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"

			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and its how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
	#'
fi

#Guava9th
if [ "$input_number" -eq 22 ] || [ "$input_number" -eq 1 ]; then
	#for EXEC_NUM in {1..3}; do
		#experiment
		project_name="GUAVA9TH"
		#experiment folder name
		string1="guava9th"
		#name of the .java file
		run_file_name="RunGuava9th"
		run_file="RunFiles/$run_file_name.java"
		#array containing the benchmarks
		benchmarks_array=("GUAVA-71" "GUAVA-273" "GUAVA-11" "GUAVA-999" "GUAVA-998" "GUAVA-200" "GUAVA-192" "GUAVA-96" "GUAVA-267" "GUAVA-232" "GUAVA-156" "GUAVA-118" "GUAVA-213" "GUAVA-148")
		#benchmarks_array=("GUAVA-999")
		#length
		number=${#benchmarks_array[@]}

		echo "[TARDIS LAUNCHER] project_name = $project_name, run_file = $run_file, found $number benchmarks"

		mkdir $LOG_PATH/$dt/$project_name
		#copy runtool to the LOG_PATH folder to make the coverage tool happy
		cp -f $REPO_HOME_PATH/CovarageTool/runtool $LOG_PATH/$dt/$project_name

		#set evosuiteMultiSearch
		sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" $run_file
		sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" $run_file

		for BENCHMARK in "${benchmarks_array[@]}"; do
			echo "[TARDIS LAUNCHER] Run benchmark $project_name -- Target class: $BENCHMARK"

			#set the Tardis run files with the current target class
			sed -i "s/\(setTargetClass(\).*\();\)/\1${BENCHMARK/-/_}\2/g" $run_file

			#compile the run files
			bash CompileAndMove.sh

			timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/$string1/guava/target/guava-29.0-jre.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/failureaccess-1.0.1.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/checker-qual-2.11.1.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/error_prone_annotations-2.3.4.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/srczip-999.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/j2objc-annotations-1.3.jar:$REPO_HOME_PATH/$string1/guava/target/dependency/jsr305-3.0.2.jar:$REPO_HOME_PATH/$string1/guava/target:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar settings.$run_file_name |& tee $LOG_PATH/$dt/$project_name/tardisLog$BENCHMARK.txt
			echo "[TARDIS LAUNCHER] Tardis execution finished. Calculate results"
			
			#extract the tardis-tmp folder
			TMPDIR=$(ls -td $REPO_HOME_PATH/$string1/tardis-tmp/* | head -1)

			#Perform Jacoco
			echo "[TARDIS LAUNCHER] JACOCO"

			source JacoLaunch.sh
			
			#Clean filesystem if necessary
			foldersize=$(du -sm $TMPDIR | cut -f1)
			if [[ $foldersize -gt $sizeThreshold ]]; then
				mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR "${TMPDIR}_lite" ; rm -r $TMPDIR
			fi
		done

		

		#number was already set before and it's how many benchmarks were executed
		#string1 was already set too, as the experiment folder name
		string2="" #result name
		if [ "$evosuiteMultiSearch" = "true" ]; then
			string2="$project_name EXEC-$EXEC_NUM classifier"
		else
			string2="$project_name EXEC-$EXEC_NUM no multiSearch"
		fi

		cd /dev/hd2/tardisBenattiScripts

		echo "[TARDIS LAUNCHER] NewGenerateResult"

		source NewGenerateResult.sh

		cd "$REPO_HOME_PATH"
	#done
fi

#MIPC
if [ "$input_number" -eq 23 ] || [ "$input_number" -eq 1 ]; then
	globalTime=60

	mkdir -p $LOG_PATH/$dt/MIPC

	sed -i "s/\(.*\)setEvosuiteMultiSearch.*/\1setEvosuiteMultiSearch($evosuiteMultiSearch);/" RunFiles/RunMIPC.java
	sed -i "s/\(.*\)setGlobalTimeBudgetDuration.*/\1setGlobalTimeBudgetDuration($globalTime);/" RunFiles/RunMIPC.java
	
	BENCHMARK="MIPC"
	
	echo "[TARDIS LAUNCHER] Run MIPC -- Target class: $BENCHMARK"
		
	bash CompileAndMove.sh
		
	timeout -s 9 $timeoutTime java $javaMem -cp $REPO_HOME_PATH/mipc/bin:$TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/libs/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$TOOLSJAR_PATH/tools.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/com.github.javaparser/javaparser-core/3.15.9/998ab964f295e6cecd4467a76d4a6369a8193e5a/javaparser-core-3.15.9.jar:$TARDIS_HOME_PATH/jbse/libs/javassist.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.jacoco/org.jacoco.core/0.7.5.201505241946/1ea906dc5201d2a1bc0604f8650534d4bcaf4c95/org.jacoco.core-0.7.5.201505241946.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.ow2.asm/asm-debug-all/5.0.1/f69b5f7d96cec0d448acf1c1a266584170c9643b/asm-debug-all-5.0.1.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar RunMIPC |& tee $LOG_PATH/$dt/MIPC/tardisLog$BENCHMARK.txt
		
	echo "[TARDIS LAUNCHER] Tardis execution finished. You have to create the folder in /dev/hd2/tardisBenattiScripts/results by yourself"
	echo "(execute /dev/hd2/tardisBenattiScripts/GenerateResult.sh with the arguments 'mipc' and a string for the result folder name)"
		
	TMPDIR=$(ls -td $REPO_HOME_PATH/mipc/tardis-tmp/* | head -1)
		
	foldersize=$(du -sm $TMPDIR | cut -f1)
	if [[ $foldersize -gt $sizeThreshold ]]; then
		mkdir "${TMPDIR}_lite" ; cp -r $TMPDIR/test "${TMPDIR}_lite" ; rm -r $TMPDIR
	fi
fi

#if set, stop system resources logging script
#if [ $systemlogging == "1" ]; then
#	kill $SystemLoadLogging_PID
#fi

echo "[TARDIS LAUNCHER] ENDING at $(date)"