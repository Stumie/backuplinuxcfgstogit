#!/bin/bash

set -e

# Logging function to make console output look better
log () {
    echo "$0 - $@"
}

# Logging function to use for piped outputs
outputlogger (){
    while read -r subline; do log "$subline"; done
} 

# Script will only run with the correct number of parameters provided
if (( $# != 4 )); then
  log "ABORT. Not all or too many parameters provided"
  exit 1
fi

# Set variables
TARGETDIR=$HOME/$(basename $0)_repospace
FILELISTPATH=$(realpath $1)
GITUSER=$2
GITUSEREMAIL=$3
GITREMOTEREPOURL=$4

# Prepare automated git commit message
TEMPCOMMITMSG=$HOME/temp_$(basename $0)_commitmessage.$(date +%Y%m%dT%H%M%S)
cat << EOF > $TEMPCOMMITMSG
Automated backup from $(hostname -f) on $(date +%Y-%m-%dT%T)
Files:
$(cat $FILELISTPATH)
EOF

log "Home directory from executing user is $HOME"

#################################################################################################

if [[ -d "$TARGETDIR" ]]; then
  rm -vrf $TARGETDIR | outputlogger
fi
git clone $GITREMOTEREPOURL $TARGETDIR | outputlogger
git -C $TARGETDIR config user.name $GITUSER | outputlogger
git -C $TARGETDIR config user.email $GITUSEREMAIL | outputlogger

# Copy files to local git repository
log "Reading from file list $FILELISTPATH"
file=$(cat "$FILELISTPATH" | awk NF)
for line in $file; do

    [[ $line = \#* ]] && continue # Exclude outcommented files

    TARGETPATH=( "$TARGETDIR$(dirname $line)" )

    log "Create $TARGETPATH if necessary"
    mkdir -pv $TARGETPATH | outputlogger

    log "Copy $line to $TARGETPATH if necessary"
    rsync -ahv $line $TARGETPATH | outputlogger

done

# Add files to local git and push them to remote repository
git -C $TARGETDIR add . | outputlogger
git -C $TARGETDIR commit -a -F $TEMPCOMMITMSG | outputlogger
rm -vf $TEMPCOMMITMSG | outputlogger
git -C $TARGETDIR push | outputlogger