#!/bin/bash

# Init script for source-auto tool (DON'T CHANGE)

SOURCE_AUTO_DIR=~/.source-auto/bash
for filename in $SOURCE_AUTO_DIR/*; do
    [ -f "$filename" ] || continue
    source $(readlink -f $filename)
done
