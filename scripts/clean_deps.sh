#!/bin/bash

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
PROJECT_PATH="$(dirname "$SCRIPT_PATH")"
EXTERNAL_PATH="backend/ext"

################# CLEAN EXTERNAL LIBRARY #################
echo -n "Reading files..."
sleep 1
cd "$EXTERNAL_PATH" || exit

FILES_TO_DELETE=$(ls | grep -v "README.md")
FILE_COUNT=$(echo "$FILES_TO_DELETE" | wc -l)

if [ -z "$FILES_TO_DELETE" ]; then
    echo -e "\nNo files to delete."
else
    echo -e "\rThe following $FILE_COUNT items will be deleted and cannot be recovered:"
    echo
    echo "$FILES_TO_DELETE"
    echo
    read -p "Do you want to remove them? (Y/N): " answer
    case "$answer" in
        *[Yy]* )
            DELETED_COUNT=$(rm -vrf $FILES_TO_DELETE | wc -l)
            echo "$DELETED_COUNT items deleted."
            exit 0
        ;;
        * )
            echo "Deletion canceled."
            exit 0
        ;;
    esac
fi

cd "$PROJECT_PATH" || exit