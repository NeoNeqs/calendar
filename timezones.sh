#!/usr/bin/env bash

ZONEINFO_DIR="/usr/share/zoneinfo"
OUTPUT_FILE="timezones.json"

# Collect all valid timezones
mapfile -t timezones < <(
    find "$ZONEINFO_DIR" \
        -type f \
        ! -path "$ZONEINFO_DIR/posix/*" \
        ! -path "$ZONEINFO_DIR/right/*" \
        ! -name "zone.tab" \
        ! -name "zone1970.tab" \
        ! -name "leapseconds" \
        ! -name "localtime" \
        | sed "s|$ZONEINFO_DIR/||" \
        | sort
)

# Start the JSON object
echo "{" > "$OUTPUT_FILE"

len=${#timezones[@]}
for i in "${!timezones[@]}"; do
    tz="${timezones[i]}"

    # Get the UTC offset in +HHMM or -HHMM
    offset_str=$(TZ="$tz" date +%z)

    # Convert to total minutes
    sign=${offset_str:0:1}
    hours=${offset_str:1:2}
    minutes=${offset_str:3:2}
    total_minutes=$((10#$hours * 60 + 10#$minutes))
    if [[ "$sign" == "-" ]]; then
        total_minutes=$(( -total_minutes ))
    fi

    # Add comma except for last entry
    if (( i < len - 1 )); then
        echo "    \"$tz\": $total_minutes," >> "$OUTPUT_FILE"
    else
        echo "    \"$tz\": $total_minutes" >> "$OUTPUT_FILE"
    fi
done

# End the JSON object
echo "}" >> "$OUTPUT_FILE"

echo "Time zones with offsets saved to $OUTPUT_FILE"
