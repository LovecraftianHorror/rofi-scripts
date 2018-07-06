#!/usr/bin/env bash

if [ ! -f web-search.cfg ]; then
    echo "Error: could not find config 'web-search.cfg' when launching web-search.sh"
    exit 1
fi

. ./web-search.cfg

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
                                     -columns $COLUMNS   \
                                     -p "$ENGINE_PROMPT" \
    )

    if [ "$?" -ne 0 ]; then
        exit 1
    fi

    if [ "$USE_ENGINE_FOR_QUERY_PROMPT" = true ]; then
        QUERY_PROMPT="$engine_name"
    fi

    query=$( rofi -dmenu -lines 0 -p "$QUERY_PROMPT" )
    if [[ -n "$query" ]]; then
        url="${ENGINES[$engine_name]}$query"
        xdg-open "$url"
    fi
}

main
exit 0
