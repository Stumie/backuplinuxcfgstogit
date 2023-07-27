# backuplinuxcfgstogit
Script to automate Debian GNU/Linux config backup into a Git repo

## Dependencies
Install dependencies (`coreutils` and `git`) before using this script, e. g. like this:
```
sudo apt update && sudo apt install coreutils rsync git -y
```

## Usage like e. g.
```
./backuplinuxcfgstogit.sh ./example-file-list.txt gitusername username@emailprovier.com git@github.com:user/target-git-repository-from-user.git
```
## Make it regular
You might want to create a regular cron job for the script to take action, e. g. a file like this:
```
root@machine:~# cat /etc/cron.weekly/trigger-backuplinuxcfgstogit
#!/bin/bash

eval "$(ssh-agent -s)"
ssh-add .ssh/github
./backuplinuxcfgstogit.sh ./example-file-list.txt gitusername username@emailprovier.com git@github.com:user/target-git-repository-from-user.git >> /tmp/backuplinuxcfgstogit.log
```
