#!/bin/bash

echo ""
echo "Regenerating files.json..."

# GitHub Pages base URL
BASE_URL="https://classicvinyl.github.io/audio-player"

# Output file
FILES_JSON="files.json"

# Start JSON
echo "[" > "$FILES_JSON"

first_playlist=true

# Loop through subdirectories only
for dir in */ ; do
    # Skip hidden folders and non-directories
    [[ "$dir" == .* || ! -d "$dir" ]] && continue

    playlist_name="${dir%/}"
    playlist_path="$dir"

    # Find MP3 files in the playlist
    mp3_files=()
    while IFS= read -r -d $'\0' file; do
        mp3_files+=("$file")
    done < <(find "$playlist_path" -maxdepth 1 -type f -name "*.mp3" -print0 | sort -z)

    # Skip empty playlists
    [[ ${#mp3_files[@]} -eq 0 ]] && continue

    # Add comma between playlists
    if [ "$first_playlist" = false ]; then
        echo "," >> "$FILES_JSON"
    else
        first_playlist=false
    fi

    # Begin playlist object
    echo "  {" >> "$FILES_JSON"
    echo "    \"playlist\": \"${playlist_name}\"," >> "$FILES_JSON"
    echo "    \"tracks\": [" >> "$FILES_JSON"

    # Add tracks
    for i in "${!mp3_files[@]}"; do
        filepath="${mp3_files[$i]}"
        filename=$(basename -- "$filepath")
        name="${filename%.*}"
        url="$BASE_URL/$filepath"

        # Clean path for URL (remove spaces, etc.)
        url="${url// /%20}"

        echo "      {" >> "$FILES_JSON"
        echo "        \"title\": \"${name}\"," >> "$FILES_JSON"
        echo "        \"url\": \"${url}\"" >> "$FILES_JSON"
        if [ $i -lt $((${#mp3_files[@]} - 1)) ]; then
            echo "      }," >> "$FILES_JSON"
        else
            echo "      }" >> "$FILES_JSON"
        fi
    done

    echo "    ]" >> "$FILES_JSON"
    echo "  }" >> "$FILES_JSON"
done

# End JSON
echo "]" >> "$FILES_JSON"

echo "✅ files.json regenerated."

echo ""
echo "Adding changes..."
git add -A

echo "Committing changes..."
git commit -m "Manual sync update $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit"

echo "Discarding unstaged changes..."
git checkout -- .

echo "Pulling latest changes..."
git pull --rebase

echo "Pushing to GitHub..."
git push

echo "✅ Sync complete."
