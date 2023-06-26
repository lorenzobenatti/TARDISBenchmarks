#!/bin/bash

# specificare la cartella in cui cercare le cartelle da eliminare
folder_path="/dev/hd2/tardisFolderManetti/TARDISBenchmarks-junitcontest"

# cambiare la directory corrente alla cartella di destinazione
cd "$folder_path"

# eliminare i file con nome che inizia con "hs_"
find . -type f -name "replay*" -delete

