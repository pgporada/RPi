#!/bin/bash
TODAY=$(date +%Y_%m_%d)
YESTERDAY=$(date -d "1 day ago" +%Y_%m_%d)

cd /opt/storage/

# Remove old folders/files
find .  -maxdepth 2 -type d ! -type l -mtime +22 -exec rm -rf {} \;

# If todays dir doesn't exist then make it
if [ ! -d "${TODAY}/" ] ; then
    mkdir -p ${TODAY}/{thumbnails,big}
    
    # Crontab runs at 0 0 * * * so swap symlinks and make it all pretty and shit
    rm -f previous
    
    # Check if symlink exists
    if [ -L "current" ] ; then 
        mv current previous
        ln -s ${TODAY} current
    else
        ln -s ${TODAY} current
    fi
fi
