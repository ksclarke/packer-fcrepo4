#! /bin/bash

CLASSES=(`sudo find / -name "*.jar" -exec jar -tf {} \; | grep "\.class\$"`)
IFS=$'\n' SORTED=($(sort <<<"${CLASSES[*]}"))

for CLASS in "${SORTED[@]}"; do
  echo $CLASS
done