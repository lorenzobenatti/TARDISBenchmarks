#!/bin/bash

#Some paths and settings
REPOSITORYHOMEPATH="/dev/hd2/TARDISBenchmarks"
TARDISHOMEPATH="/dev/hd2/tardisFolderBenatti"
jacoco_agent="$REPOSITORYHOMEPATH/CovarageTool/lib/jacocoagent.jar"
junit_jar="$REPOSITORYHOMEPATH/CovarageTool/junit-4.12.jar"
hamcrest_jar="$REPOSITORYHOMEPATH/CovarageTool/junit4-r4.13.2/lib/hamcrest-core-1.3.jar"
jacoco_cli="$REPOSITORYHOMEPATH/CovarageTool/lib/jacococli.jar"
file="$REPOSITORYHOMEPATH/benchmarksListBenatti.list"
BENCH=$BENCHMARK
echo "[JACOCO LAUNCHER] Calculate results for $BENCHMARK"

#EXTRACT FROM .list FILE:
section=$(grep -A 6 "$BENCH=" "$file")
src=$(echo "$section" | grep "src" | awk -F '=' '{print $2}')
bin_classes=$(echo "$section" | grep "bin" | awk -F '=' '{print $2}')
packages=$(echo "$section" | grep "classes" | awk -F '=' '{print $2}' | tail -n +2 | head -1)
classpath_list=$(echo "$section" | grep "classpath" | awk -F '=' '{print $2}')
project=$(echo "$section" | grep "project" | awk -F '=' '{print $2}')

echo "[JACOCO LAUNCHER] Calculate results for packages: $packages"

packages=$(echo "$packages" | sed 's/\.[^.]*$//')
src=$(echo "$src" | sed "s|\$REPOSITORYHOMEPATH|$REPOSITORYHOMEPATH|")
bin_classes=$(echo "$bin_classes" | sed "s|\$REPOSITORYHOMEPATH|$REPOSITORYHOMEPATH|")
classpath_list=$(echo "$classpath_list" | sed "s#\$REPOSITORYHOMEPATH#$REPOSITORYHOMEPATH#g")
classpath_list=$(echo "$classpath_list" | sed "s#\$TARDISHOMEPATH#$TARDISHOMEPATH#g")

#bin_classes necessita del path packages non puntato bens� backslashato

# Print the extracted variables
#echo "src: $src"
#echo "bin: $bin_classes""
#echo "classpath_list: $classpath_list"
#echo "project: $project"


#PATH FOR THE CLASSES BIN 
new_path_classes=$(echo "$packages" | sed 's/\./\//g')
#echo "bin_classesOLD: $bin_classes"
bin_classes="$bin_classes/$new_path_classes"
#echo "bin classes: $bin_classes"

#PATH FOR THE CLASSES sourcefiles
classes_source_folder="$src/$new_path_classes"
echo "classes source: $classes_source_folder"

#MAKE A IF CONTROL FOR EXISTENCE OF THE FOLDER (SOMETIMES IT GOT NOT GENERATED)

#LOOK FOR FOLDER WITH THE LATEST DATETIME
tests_folder_run="$REPOSITORYHOMEPATH/$project/tardis-tmp"
x_folder="$(find "$tests_folder_run" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -n | tail -n 1)"
tests_path_run="$tests_folder_run/$x_folder/bin"
#echo "$tests_path_run"

inner_folder_path="$tests_path_run"
while [ "$(find "$inner_folder_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | wc -l)" -eq 1 ]; do
  inner_folder="$(find "$inner_folder_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')"
  inner_folder_path="$inner_folder_path/$inner_folder"
done
tests_path="$inner_folder_path"
#echo "$tests_path"

#Pass all test class
tests=""
prefix="Test" #non prefisso ma se ha test nel nome
# Loop through all files in the tests folder
for file in $tests_path/*.class; do
  # Get the file name without the '.class' extension
  file_name="$(basename "$file" .class)"
  # Append the file name with the correct format to the tests variable taking only Tests and no Wrapper
  #tests="$tests $project.$file_name"
  if [[ $file_name == *"$prefix"* ]]; then
    tests="$tests $packages.$file_name"
  fi
done

#classpth definitivo
class_path="$bin_classes:$tests_path_run:$junit_jar:$hamcrest_jar:$classpath_list"
#echo "class_path: $class_path"

#Launch jacoco for javaagent
java -javaagent:"$jacoco_agent" -cp "$class_path" org.junit.runner.JUnitCore $tests

echo "[JACOCO LAUNCHER] Create JACOCOCLI report htlm for $BENCHMARK"

# Run jacoco.cli for generate html coverage results
java -jar "$jacoco_cli" report jacoco.exec --classfiles "$bin_classes" --sourcefiles "$classes_source_folder" --html report

#MOVING THE FOLDER IN OTHER PATH
result_path="$REPOSITORYHOMEPATH/$project/resultNestClass/report$BENCH"
mv report $result_path
echo "move results to: $result_path" 

rm jacoco.exec
