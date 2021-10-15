#!/bin/bash 

git remote add template git@github.com:d3estudio/d3-lib.git

git fetch --all 

git merge template/master --allow-unrelated-histories

git remote remove template

echo "D3-Lib Updated! please commit for the update to be completed..."