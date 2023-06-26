#!/bin/bash

# must be executed by the launcher

if [ -z "$number" ] || [ -z "$string1" ] || [ -z "$string2" ]; then
    echo "[GENERATE RESULT] Invalid variables provided. Please set a number (how many benchmarks were executed), as the number variable, and two strings (the experiment folder name, like \"core-release-13.3.0\", and the result name, like \"AUTHZFORCE my params - classifier\") as the variables string1 and string2 respectively."
    exit 1
fi

if ! [[ $number =~ ^[0-9]+$ ]]; then
    echo "[GENERATE RESULT] Invalid number argument. Please pass a valid number as the first argument."
    exit 1
fi

if [ ! $number -gt 0 ]; then
    echo "[GENERATE RESULT] The number is not greater than 0."
fi

if [[ -z $string1 ]]; then
    echo "[GENERATE RESULT] No string1 argument provided. Please pass a string as the second argument."
    exit 1
fi

if [[ -z $string2 ]]; then
    echo "[GENERATE RESULT] No string2 argument provided. Please pass a string as the third argument."
    exit 1
fi

path="/dev/hd2/TARDISBenchmarks/$string1"

if [[ ! -d $path ]]; then
    echo "[GENERATE RESULT] $path is not a valid path."
    exit 1
fi

tardis_tmp="$path/tardis-tmp"

if [[ ! -d $tardis_tmp ]]; then
    echo "[GENERATE RESULT] $tardis_tmp is not a valid path."
    exit 1
fi

cd /dev/hd2/tardisBenattiScripts/results

mkdir -p "$string2"

cd "$string2"

mkdir -p "console logs"

mkdir -p "tmp folders"

cd ..


# Get the most recently created directories sorted by time
directories=$(ls -dt "/dev/hd2/TARDISBenchmarks/Reports"/*/)

# Extract the desired number of directories
selected_dirs=$(echo "$directories" | head -n $number)

# Copy the reports
cp -r $selected_dirs "/dev/hd2/tardisBenattiScripts/results/$string2"

echo "[GENERATE RESULTS] Copied $number reports"


# Get the most recently created directory
most_recent_dir=$(ls -dt "/dev/hd2/tardisBenattiScripts/tardisLogs"/*/ | head -n 1)

# Copy the logs
cp -r "$most_recent_dir" "/dev/hd2/tardisBenattiScripts/results/$string2/console logs"

echo "[GENERATE RESULTS] Copied the logs"


# Get the most recently created directories sorted by time
directories_tmp=$(ls -dt "$tardis_tmp"/*/)

# Extract the desired number of directories
selected_dirs_tmp=$(echo "$directories_tmp" | head -n $number)

# Copy the tmp folders
cp -r $selected_dirs_tmp "/dev/hd2/tardisBenattiScripts/results/$string2/tmp folders"

echo "[GENERATE RESULTS] Finished, copied the tmp folders too."
