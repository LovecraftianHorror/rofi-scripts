#!/usr/bin/env bash

if [ ! -f config ]; then
    echo "Error: could not find config 'config' when launching web-searcher.sh"
    exit 1
fi

. ./config

# List for rofi
gen_list() {
    for i in "${!ENGINES[@]}"
    do
        echo "$i"
    done
}

main() {
    # Pass the list to rofi
    engine_name=$( (gen_list) | rofi -dmenu -fuzzy -only-match -location 0 -p "$ENGINE_PROMPT" )

    if [ "$USE_ENGINE_FOR_QUERY_PROMPT" = true ]; then
        QUERY_PROMPT="$engine_name"
    fi

    query=$( (echo ) | rofi  -dmenu -fuzzy -location 0 -p "$QUERY_PROMPT" )
    if [[ -n "$query" ]]; then
        url="${ENGINES[$engine_name]}$query"
        xdg-open "$url"
    else
        rofi -show -e "No query provided."
    fi
}

main
exit 0
