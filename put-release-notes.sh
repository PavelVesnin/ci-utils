#!/bin/bash
# This script create a text file with build changelog in release_notes dir.
# Depents on env. variables set by: fetch-project-environment.sh and fetch-source-version.sh

MINOR_VERSION=$(echo "${NEXT_VERSION}" | cut -d. -f1,2)
FULL_MINOR_VERSION="${MINOR_VERSION}.0"

RELEASE_NOTES_DIR="${PROJECT_DIR}/release_notes"
RELEASE_NOTES_FILE="$RELEASE_NOTES_DIR/${MINOR_VERSION}.txt"

# Get changelog from minor ver to HEAD
if [[ $MINOR_VERSION == "0.1.0" ]]; then
  GIT_HISTORY=$(git log --no-merges --format="%B")
else
  GIT_HISTORY=$(git log --no-merges --format="%B" $FULL_MINOR_VERSION..HEAD)
fi;

GIT_HISTORY_CLEANED=$(echo "${GIT_HISTORY}" | grep -v 'ci skip' | grep -v 'changelog skip' | sed 's/^* //g')
MAJOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[major\]')
MINOR_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[minor\]')
PATCH_CHANGES=$(echo "${GIT_HISTORY_CLEANED}" | grep -i '\[patch\]')

# Save all changes notes to file
echo "[I] Creating release notes for '${MINOR_VERSION}'-'${NEXT_VERSION}' in 'release_notes'."

if [ ! -d $RELEASE_NOTES_DIR ]; then
  mkdir $RELEASE_NOTES_DIR
fi

CHANGELOG=""

if [[ "${MAJOR_CHANGES}" != "" ]]; then
  CHANGELOG="**Major changes**: "$'\n\n'"${MAJOR_CHANGES}"$'\n\n'
fi;

if [[ "${MINOR_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Minor changes**: "$'\n\n'"${MINOR_CHANGES}"$'\n\n'
fi;

if [[ "${PATCH_CHANGES}" != "" ]]; then
  CHANGELOG="${CHANGELOG}**Patches and bug fixes**: "$'\n\n'"${PATCH_CHANGES}"
fi;

if [[ "${CHANGELOG}" != "" ]]; then
  echo -e "${CHANGELOG}" > $RELEASE_NOTES_FILE
fi;