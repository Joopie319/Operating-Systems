#!/bin/bash

# Check if two parameters are given
if [ "$#" -ne 2 ]; then
    echo "Gebruik: $0 <directory_met_fotos> <maand|week>"
    exit 1
fi

# Variables
PHOTO_DIR=$1
MODE=$2
TARGET_DIR="$PHOTO_DIR/sorted"
CURRENT_DATE=$(date +%s)

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Function to calculate the week number or month directory
move_photo() {
    local file=$1

    if [ "$MODE" == "week" ]; then
        # Get week number
        SUBFOLDER=$(date -r "$file" +%Y_week_%U)
    elif [ "$MODE" == "maand" ]; then
        # Get month
        SUBFOLDER=$(date -r "$file" +%Y_%B)
    else
        echo "Ongeldige optie voor de tweede parameter. Gebruik 'maand' of 'week'."
        exit 1
    fi

    # Create the target subdirectory if it doesn't exist
    mkdir -p "$TARGET_DIR/$SUBFOLDER"

    # Copy the file to the target directory
    cp "$file" "$TARGET_DIR/$SUBFOLDER/"

    # Verify the MD5 checksum
    ORIG_HASH=$(md5sum "$file" | awk '{print $1}')
    NEW_HASH=$(md5sum "$TARGET_DIR/$SUBFOLDER/$(basename "$file")" | awk '{print $1}')

    if [ "$ORIG_HASH" == "$NEW_HASH" ]; then
        # Remove the original file only if the hashes match
        rm "$file"
        echo "$file is succesvol verplaatst naar $TARGET_DIR/$SUBFOLDER"
    else
        echo "Fout: Het kopiëren van $file is mislukt. Het bestand blijft op de originele locatie."
    fi
}

# Loop through the photo files in the directory
for photo in "$PHOTO_DIR"/*.{jpg,jpeg,png}; do
    if [ -f "$photo" ]; then
        move_photo "$photo"
    fi
done
