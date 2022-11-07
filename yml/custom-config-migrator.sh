#!/bin/bash

VERSION=your_thingsboard_version
TB_PE_MOD_YML="thingsboard.yml"

for i in "$@"
do
case $i in
    --version=*)
    VERSION="${i#*=}"
    shift
    ;;
    *)
            #unknown option
    ;;
esac
done

if [ "$1" ]; then
	TB_PE_MOD_YML="$1"
fi

TB_PE_ORIGINAL_YML="pe-${VERSION}.yml"
TB_PE_ORIGINAL_YML_SOURCE="https://raw.githubusercontent.com/thingsboard/ThingsboardSupport/main/yml/pe-yml/${TB_PE_ORIGINAL_YML}"
DIFF_YML="differences.yml"
OUTPUT="output.conf"


wget -nv -O "$TB_PE_ORIGINAL_YML" "$TB_PE_ORIGINAL_YML_SOURCE" 

diff -a "$TB_PE_ORIGINAL_YML" "$TB_PE_MOD_YML" > "$DIFF_YML"

grep \> "$DIFF_YML" | grep -o "\${.*}" > $OUTPUT


sed -i 's/${/export /' $OUTPUT
sed -i 's/}//' $OUTPUT
sed -i 's/:/=/' $OUTPUT
cat $OUTPUT

