#!/bin/bash

echo "Regenerating files.json..."

# Create a fresh files.json
echo "[" > files.json

first=true
for file in *.mp3; do
  [ -e "$file" ] || continue

  name="${file%.mp3}"
  url="https://classicvinyl.github.io/audio-player/$file"

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> files.json
  fi

  echo "  {\"name\": \"$name\", \"url\": \"$url\"}" >> files.json
done

echo "]" >> files.json

echo "Committing and pushing changes to GitHub..."

git add files.json
git commit -m "Manual sync update $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✅ Sync complete."
