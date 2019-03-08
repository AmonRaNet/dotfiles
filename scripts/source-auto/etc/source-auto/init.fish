#!/bin/fish

# Init script for source-auto tool (DON'T CHANGE)

set SOURCE_AUTO_DIR ~/.source-auto/fish
for filename in $SOURCE_AUTO_DIR/*
    source (readlink -f $filename)
end
