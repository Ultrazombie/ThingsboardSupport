#!/bin/bash

VERSION=your_thingsboard_version

TB_PE_ORIGINAL_YML="pe-${VERSION}.yml"
TB_PE_ORIGINAL_YML_SOURCE="https://raw.githubusercontent.com/thingsboard/ThingsboardSupport/main/yml/${TB_PE_ORIGINAL_YML}"
TB_PE_MOD_YML="thingsboard.yml"
DIFF_YML="differences.yml"
OUTPUT="output.conf"

if [ "$1" ]; then
	TB_PE_MOD_YML="$1"
fi

wget -nv -O "$TB_PE_ORIGINAL_YML" "$TB_PE_ORIGINAL_YML_SOURCE" 

diff -a "$TB_PE_ORIGINAL_YML" "$TB_PE_MOD_YML" > "$DIFF_YML"

grep \> "$DIFF_YML" | grep -o "\${.*}" > $OUTPUT


sed -i 's/${/export /' $OUTPUT
sed -i 's/}//' $OUTPUT
sed -i 's/:/=/' $OUTPUT
cat $OUTPUT

