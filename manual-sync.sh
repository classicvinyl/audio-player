#!/bin/bash

echo "Regenerating tracks.json..."

# Create a fresh tracks.json
echo "[" > tracks.json

first=true
for file in *.mp3; do
  [ -e "$file" ] || continue

  url="https://classicvinyl.github.io/audio-player/$file"
  name="${file%.*}"

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> tracks.json
  fi

  echo "  {\"name\": \"$name\", \"url\": \"$url\"}" >> tracks.json
done

echo "]" >> tracks.json

echo "Committing and pushing changes to GitHub..."

git add .
git commit -m "Manual sync update $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✅ Sync complete."
