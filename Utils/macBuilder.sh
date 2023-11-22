#!/bin/bash

# Usage: bash macBuilder.sh <6(+) character word>

echo -n $1 | od -A n -t x1 |sed 's/^[ \t]*//;s/[ \t]*$//'| cut -d ' ' -f -6 | tr ' ' ':'