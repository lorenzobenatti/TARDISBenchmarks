#!/bin/bash

#Some paths and settings
REPOSITORYHOMEPATH="/dev/hd2/TARDISBenchmarks"
TARDISHOMEPATH="/dev/hd2/tardisBenatti"
jacoco_agent="$REPOSITORYHOMEPATH/CovarageTool/lib/jacocoagent.jar"
junit_jar="$REPOSITORYHOMEPATH/CovarageTool/junit-4.12.jar"
hamcrest_jar="$REPOSITORYHOMEPATH/CovarageTool/hamcrest-core-1.3.jar"
jacoco_cli="$REPOSITORYHOMEPATH/CovarageTool/lib/jacococli.jar"
file="$REPOSITORYHOMEPATH/CovarageTool/benchmarks.list"
BENCH=$BENCHMARK
echo "[JACOCO LAUNCHER] Calculate results for $BENCHMARK"

date=$(date +%Y_%m_%d_%H_%M_%S)
export date

#EXTRACT FROM .list FILE:
#section=$(grep -A 6 "$BENCH=" "$file") sorry...
section=$(sed -n '/'"$BENCH"'=/{:a;N;/}/!ba;p}' "$file")
src=$(echo "$section" | grep "src=" | cut -d'=' -f2)
bin_classes=$(echo "$section" | grep "bin=" | cut -d'=' -f2)
classes=$(echo "$section" | awk '/classes=\(/ {getline; gsub(/^[[:blank:]]+/, ""); print}')
classpath_list=$(echo "$section" | awk '/classpath=\(/ {getline; gsub(/^[[:blank:]]+/, ""); print}')
classpath_list="${classpath_list//,/:}"

#some messages to check if everything was extracted correctly
echo "[JACOCO LAUNCHER] section = $section"
echo "[JACOCO LAUNCHER] src = $src"
echo "[JACOCO LAUNCHER] bin_classes = $bin_classes"
echo "[JACOCO LAUNCHER] classpath_list = $classpath_list"

# Get tardis-tmp

aaaaa=$(echo "$src" | cut -d'/' -f1-2)
echo "[JACOCO LAUNCHER] aaaaa = $aaaaa"
tests_folder_run=$(echo "$src" | cut -d'/' -f1-2)"/tardis-tmp"
echo "[JACOCO LAUNCHER] tests_folder_run = $tests_folder_run"
tests_folder_run="${tests_folder_run//REPOSITORYHOMEPATH/$REPOSITORYHOMEPATH}"
if ! [[ -d "$tests_folder_run" ]]; then
  echo "[JACOCO LAUNCHER] Something went wrong, $tests_folder_run isn't a valid directory"
else
  echo "[JACOCO LAUNCHER] tardis-tmp folder = $tests_folder_run"
fi

echo "[JACOCO LAUNCHER] Calculate results for classes: $classes"

actual_class_name=$(echo "$classes" | awk -F '.' '{print $NF}')
# the last word after .

package=$(echo "$classes" | sed 's/\.[^.]*$//') # remove last dot and everything after
echo "[JACOCO LAUNCHER] package = $package"
#src=$(echo "$src" | sed "s|\$REPOSITORYHOMEPATH|$REPOSITORYHOMEPATH|")
src="${src//REPOSITORYHOMEPATH/$REPOSITORYHOMEPATH}"
#bin_classes=$(echo "$bin_classes" | sed "s|\$REPOSITORYHOMEPATH|$REPOSITORYHOMEPATH|")
bin_classes="${bin_classes//REPOSITORYHOMEPATH/$REPOSITORYHOMEPATH}"
#classpath_list=$(echo "$classpath_list" | sed "s#\$REPOSITORYHOMEPATH#$REPOSITORYHOMEPATH#g")
#classpath_list=$(echo "$classpath_list" | sed "s#\$TARDISHOMEPATH#$TARDISHOMEPATH#g")
classpath_list="${classpath_list//REPOSITORYHOMEPATH/$REPOSITORYHOMEPATH}"
classpath_list="${classpath_list//TARDISHOMEPATH/$TARDISHOMEPATH}"

#bin_classes necessita del path packages non puntato bensì backslashato

# Print the extracted variables
#echo "[JACOCO LAUNCHER] Sources: $src"
#echo "bin: $bin_classes""
#echo "classpath_list: $classpath_list"
#echo "project: $project"

#PATH FOR THE CLASSES BIN 
new_path_classes=$(echo "$package" | sed 's/\./\//g')
#echo "bin_classesOLD: $bin_classes"
#bin_classes="$bin_classes/$new_path_classes"
#bin_classes="$bin_classes"
echo "[JACOCO LAUNCHER] new_path_classes = $new_path_classes"

#PATH FOR THE CLASSES sourcefiles
#src_copy=$src
#remove last character if it's a /
#if [[ "${src_copy: -1}" == "/" ]]; then
#  src_copy="${src_copy%?}"
#fi
#src_copy is like src but without a / at the end
#classes_source_folder="$src_copy/$new_path_classes"
#echo "[JACOCO LAUNCHER] classes_source_folder = $classes_source_folder"

#LOOK FOR FOLDER WITH THE LATEST DATETIME
x_folder="$(find "$tests_folder_run" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -n | tail -n 1)"
tests_path_run="$tests_folder_run/$x_folder/bin"
#echo "Test folder found: $tests_path_run"

#specific_source_path="$classes_source_folder/$actual_class_name.java"
specific_class_path="$bin_classes/$new_path_classes/$actual_class_name.class"
#I want jacoco to compute the results only for a specific class

#echo "[JACOCO LAUNCHER] specific_source_path = $specific_source_path"
echo "[JACOCO LAUNCHER] specific_class_path = $specific_class_path"

inner_folder_path="$tests_path_run"
while [ "$(find "$inner_folder_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | wc -l)" -eq 1 ]; do
  inner_folder="$(find "$inner_folder_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')"
  inner_folder_path="$inner_folder_path/$inner_folder"
done
tests_path="$inner_folder_path"
#tests_path="$tests_path_run/sinergy"
#echo "[JACOCO LAUNCHER] Test folder: $tests_path"
echo "[JACOCO LAUNCHER] tests_path_run = $tests_path_run"
echo "[JACOCO LAUNCHER] tests_path = $tests_path"

#Pass all test class
tests=""
prefix="Test" #non prefisso ma se ha test nel nome
# Loop through all files in the tests folder
for file in $tests_path/*.class; do
  # Get the file name without the '.class' extension
  file_name="$(basename "$file" .class)"
  # Append the file name with the correct format to the tests variable taking only Tests and no Wrapper
  #tests="$tests $project.$file_name"
  # && ( $file_name != "Easy4TardisButHard4EvoTest" ) && ( $file_name != "Hard4TardisButEasy4EvoTest" )
  if [[ ( $file_name == *"$prefix"* ) && ( $file_name != *"scaffolding"* ) && ( $file_name != "Easy4TardisButHard4EvoTest" ) && ( $file_name != "Hard4TardisButEasy4EvoTest" ) ]]; then
    tests="$tests $package.$file_name"
  fi
done

echo "[JACOCO LAUNCHER] Tests found: $tests"

#classpath definitivo
class_path="$bin_classes:$tests_path_run:$junit_jar:$hamcrest_jar:$classpath_list"
echo "[JACOCO LAUNCHER] Class_path: $class_path"

# Launch JaCoCo with javaagent
java -javaagent:"$jacoco_agent" -cp "$class_path" org.junit.runner.JUnitCore $tests

echo "[JACOCO LAUNCHER] Create JACOCOCLI report html for $BENCHMARK"

# Run jacoco.cli TO generate html coverage results
java -jar "$jacoco_cli" report jacoco.exec --classfiles "$specific_class_path" --sourcefiles "$src" --html htmlreport

#MOVING THE FOLDER IN OTHER PATH
mkdir -p Reports/${BENCH}_report_${date}
result_path="Reports/${BENCH}_report_${date}"
mv htmlreport $result_path && echo "[JACOCO LAUNCHER] Successfully moved results to: $result_path" || echo "[JACOCO LAUNCHER] Failed to move results to: $result_path"

rm jacoco.exec
