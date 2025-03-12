#!/bin/bash

src_dir="$1"

output_dir="Output"

if [ -n "$2" ]; then
    output_dir="$2"
fi

mkdir -p "$output_dir"

c_files=("$src_dir"/*.c)

ok=false

for file in "${c_files[@]}"; do
    if [ -f "$file" ]; then
        ok=true
        file_ext=$(basename -- "$file")
        nume_fisier="${file_ext%.*}"

        gcc "$file" -o "$output_dir/$nume_fisier" 2> "$output_dir/$nume_fisier.err"
        compile_result=$?

        if [ $compile_result -eq 0 ]; then
            check_file="$src_dir/$nume_fisier.check"
            touch "$check_file"

            echo "[$nume_fisier] compilat cu succes!"

        else
            echo "[$nume_fisier] compilarea a esuat. Vezi $output_dir/$nume_fisier.err pt detalii XD."
        fi
    fi
done

for file in "${c_files[@]}"; do
    if [ -f "$file" ]; then
        file_ext=$(basename -- "$file")
        nume_fisier="${file_ext%.*}"

        ./"$output_dir/$nume_fisier" > "$output_dir/$nume_fisier.out" 2> /dev/null
            
        check_file="$src_dir/$nume_fisier.check"
        if [ -f "$check_file" ]; then

            expected_output=$(cat "$check_file")
            actual_output=$(cat "$output_dir/$nume_fisier.out")

            if [ "$expected_output" == "$actual_output" ]; then
                echo "[$nume_fisier] output la fel!"
            else
                echo "[$nume_fisier] output diferit"
            fi
        fi
    fi
done


if [ "$ok" = false ]; then
    echo "Nu exista fisiere c $src_dir."
fi

find "$output_dir" -type f -name "*.err" -size 0 -exec rm {} \;
find "$output_dir" -type f -name "*.out" -size 0 -exec rm {} \;

find "$output_dir" -type f ! -name "*.out" ! -name "*.err" -exec rm {} \;
