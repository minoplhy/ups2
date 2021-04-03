#!/bin/bash

FAIL_CODE=6

check_status() {
    LRED="\033[1;31m"   # Light Red
    LGREEN="\033[1;32m" # Light Green
    NC='\033[0m'        # No Color

    curl -sf "${1}" >/dev/null

    if [ ! $? = ${FAIL_CODE} ]; then
        echo -e "${LGREEN}${1} is online${NC}" >> index.html
    else
        echo -e "${LRED}${1} is down${NC}" >> index.html
        exit 1
    fi
}

check_status "${1}"

git clone https://github.com/minoplhy/alive-test/
rm alive-test/index.html
git add index.html
git commit -m "Autorun"
git push alive-test main
