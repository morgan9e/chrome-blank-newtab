#!/bin/bash

set -e

PAK_FILE="$(realpath $1)"
WORKDIR=$(mktemp -d)
PWD=$(pwd)

echo [*] Working at $WORKDIR
cd $WORKDIR

echo [*] Downloading https://github.com/myfreeer/chrome-pak-customizer
git clone https://github.com/myfreeer/chrome-pak-customizer
cd chrome-pak-customizer
mkdir _build
cd _build

echo [*] Building chrome-pak-customizer
cmake ../
make
cp pak $WORKDIR

cd $WORKDIR

echo [*] Unpacking resources.pak 
mkdir unpacked
./pak -u $PAK_FILE unpacked
cd unpacked

echo [*] Finding new tab page 
NEWTAB=$(zgrep -l "new_tab_page_third_party.js" *.gz)

echo [*] Found $NEWTAB

echo [*] Modifing new tab page
gzip -d $NEWTAB -c > target
sed -i 's|<script type="module" src="new_tab_page_third_party.js"></script>||' target
gzip target -c > $NEWTAB

cd $WORKDIR

echo [*] Repacking resources.pak
./pak -p unpacked/pak_index.ini $WORKDIR/resources.pak

echo [*] Installing new resources.pak
cp $PAK_FILE $WORKDIR/original
mv $PAK_FILE $PAK_FILE-orig
cp resources.pak $PAK_FILE

echo [*] Done
cd $PWD