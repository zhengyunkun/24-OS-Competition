#!/bin/bash

MY_ARRAY=("apple" "banana" "cherry")

for fruit in "${MY_ARRAY[@]}"; do
    echo $fruit
done

