#!/bin/bash

cd "/Users/user/Desktop/audio-player" || exit 1

echo "🔄 Regenerating files.json..."

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

echo "📦 Adding changes to Git..."
git add .

# Make sure we're on the correct branch and up to date
git pull --rebase

# Only commit if there are staged changes
if git diff --cached --quiet; then
  echo "⚠️ No changes to commit."
else
  git commit -m "Manual sync update $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
  echo "✅ Changes pushed to GitHub."
fi
