#!/usr/bin/env bash

find ./content -type f \( -iname \*.jpg -o -iname \*.png \) -size +6M -exec du -h '{}' + | sort -hr | head -10

toggle-draft.sh "content/family-of-edward-hallock-mills/scratch.md" "nodraft"

hugo server \
  --environment development \
  --ignoreCache \
  --noHTTPCache \
  --navigateToChanged \
  --disableFastRender \
  --forceSyncStatic \
  --gc \  # garbage collect; clears any lingering build artifacts
  #--logLevel debug  # for verbose mount/asset logs

# for large projects, increase number of inotify watchers when running server:
# echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
