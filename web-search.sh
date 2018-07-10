#!/usr/bin/env bash

# TODO:
# * Break up everything into different functions
# * Move everything that runs directly into main

if [ ! -f "$DIR/web-search.cfg" ]; then
    echo "Error: could not find config 'web-search.cfg' when launching web-search.sh"
    exit 1
fi

# Source the config
. "$DIR/web-search.cfg"

# Set default configs if variable doesn't exist
if [ -z ${var+ENGINE_PROMPT} ]; then
    ENGINE_PROMPT="Engine"
fi

if [ -z ${var+USE_ENGINE_FOR_QUERY_PROMPT} ]; then
    USE_ENGINE_FOR_QUERY_PROMPT=true
fi

if [ -z ${var+ENGINE_QUERY_PROMPT_APPEND} ]; then
    ENGINE_QUERY_PROMPT_APPEND=": "
fi

if [ -z ${var+QUERY_PROMPT} ]; then
    QUERY_PROMPT="Query"
fi

if [ -z ${var+COLUMNS} ]; then
    COLUMNS=1
fi

if [ -z ${var+CASE_SENSITIVE} ]; then
    CASE_SENSITIVE=false
fi

# Build up any configurable flags to be passed to rofi
if [ "$CASE_SENSITIVE" = false ]; then
    EXTRA_FLAGS="-i"
fi
EXTRA_FLAGS="$EXTRA_FLAGS -columns $COLUMNS"
EXTRA_FLAGS="$EXTRA_FLAGS -p $ENGINE_PROMPT"

# List for rofi
gen_list() {
    for i in "${!ENGINES[@]}"
    do
        echo "$i"
    done
}

main() {
    # Pass the list to rofi
    engine_name=$( (gen_list) | rofi -dmenu              \
                                     -no-custom          \
                                     -matching fuzzy     \
                                     $EXTRA_FLAGS        \
    )

    # Monkey See, Monkey do (Check for non-zero exit code, use non-zero exit
    # code)
    if [ "$?" -ne 0 ]; then
        exit 1
    fi

    if [ "$USE_ENGINE_FOR_QUERY_PROMPT" = true ]; then
        QUERY_PROMPT="$engine_name$ENGINE_QUERY_PROMPT_APPEND"
    fi

    query=$( rofi -dmenu -lines 0 -p "$QUERY_PROMPT" )
    if [[ -n "$query" ]]; then
        url="${ENGINES[$engine_name]}$query"
        xdg-open "$url"
    fi
}

main
exit 0
