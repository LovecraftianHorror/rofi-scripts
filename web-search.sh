#!/usr/bin/env bash

# TODO:
# * Make arg for specifying engine with a flag so that I can skip that step

DIR="`dirname $0`"
if [ ! -f "$DIR/web-search.cfg" ]; then
    rofi -show -e "Error: could not find config 'web-search.cfg' when launching web-search.sh"
    exit 1
fi

# Source the config
. "$DIR/web-search.cfg"

# Set default configs if variable doesn't exist
if [ ! -v ENGINE_PROMPT ]; then
    ENGINE_PROMPT="Engine"
fi

if [ ! -v USE_ENGINE_FOR_QUERY_PROMPT ]; then
    USE_ENGINE_FOR_QUERY_PROMPT=true
fi

if [ ! -v ENGINE_QUERY_PROMPT_APPEND ]; then
    ENGINE_QUERY_PROMPT_APPEND=": "
fi

if [ ! -v QUERY_PROMPT ]; then
    QUERY_PROMPT="Query"
fi

if [ ! -v COLUMNS ]; then
    COLUMNS=1
fi

if [ ! -v CASE_SENSITIVE ]; then
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
