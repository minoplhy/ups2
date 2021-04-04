#!/bin/bash
echo "<h1> As of 'date'</h1>" >> index.html
echo "<br>" >> index.html
FAIL_CODE=6

check_status() {
    LRED="\033[1;31m"   # Light Red
    LGREEN="\033[1;32m" # Light Green
    NC='\033[0m'        # No Color

    curl -sf "${1}" >/dev/null

    if [ ! $? = ${FAIL_CODE} ]; then
        echo -e "<b>${1}</b> is <b style="color:green">online</b>" >> /index.html
    else
        echo -e "<b>${1}</b> is <b style="color:red">down</b>" >> /index.html
        exit 1
    fi
}

check_status "${1}"

set -e
set -x

if [ -z "$INPUT_SOURCE_FILE" ]
then
  echo "Source file must be defined"
  return -1
fi

if [ -z "$INPUT_DESTINATION_BRANCH" ]
then
  INPUT_DESTINATION_BRANCH=main
fi
OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH"

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch $INPUT_DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER
cp -R "$INPUT_SOURCE_FILE" "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
cd "$CLONE_DIR"

if [ ! -z "$INPUT_DESTINATION_BRANCH_CREATE" ]
then
  git checkout -b "$INPUT_DESTINATION_BRANCH_CREATE"
  OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH_CREATE"
fi

if [ -z "$INPUT_COMMIT_MESSAGE" ]
then
  INPUT_COMMIT_MESSAGE="Update from https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing git commit"
  git push -u origin HEAD:$OUTPUT_BRANCH
else
  echo "No changes detected"
fi
