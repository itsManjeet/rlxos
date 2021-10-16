#!/bin/sh

echo -e "version: 0.1.0\nrecipes: " > pkgs/recipe
for i in recipes/*.yml ; do 
    echo "  - $(head -n1 ${i})" >> pkgs/recipe
    tail -n +2 $i | sed 's/^/    /' >> pkgs/recipe
    echo -e "\n" >> pkgs/recipe
done

source ./secure/storage

lftp -e "
set ftp:ssl-allow no
open ${STORAGE_URL}
user ${STORAGE_USERNAME} ${STORAGE_PASSWORD}
mirror --reverse --verbose ${PWD}/pkgs ${STORAGE_PATH}
bye
"
