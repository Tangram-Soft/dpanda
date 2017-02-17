#!/bin/bash
export COMMANDS=commands.txt
export OUTPUT=output.txt
export LOCALDIRS=localDirs.txt
export LOCALFILES=localFiles.txt
export REMOTEFILES=remoteFiles.txt

echo "Enter your IP address:"
read localAddress

#Reading local user password
unset localPassword
echo "Enter local user password:"
while IFS= read -p "$prompt" -r -s -n 1 char
do
  if [[ $char == $'\0' ]]
  then
    break
  fi
  prompt='*'
  localPassword+="$char"
done
echo
prompt=''

echo "Enter DataPower address:"
read dpAddress

echo "Enter DataPower administrative user:"
read dpUser

#Reading DataPower user password
unset dpPassword
echo "Enter DataPower administrative user password:"
while IFS= read -p "$prompt" -r -s -n 1 char
do
  if [[ $char == $'\0' ]]
  then
    break
  fi
  prompt='*'
  dpPassword+="$char"
done
echo

#If the user provided is not admin, we will need to specify a domain on login.
if [ "$dpUser" != "admin" ]
then
  dpPassword="$dpPassword"$'\n'default
fi

cat << EOF > $COMMANDS
$dpUser
$dpPassword
config
domain "dpanda"
base-dir dpanda:
base-dir local:
config-file dpanda.cfg
visible-domain default
url-permissions "http+https"
file-permissions "CopyFrom+CopyTo+Delete+Display+Exec+Subdir"
file-monitoring ""
config-mode local
import-format ZIP
local-ip-rewrite
maxchkpoints 3
exit
user "dpanda"
admin-state enabled
password-hashed $1$6xGVVIrb$bS0ghyvtODb1gR4b58UAm1
suppress-password-change on
access-level privileged
exit
host-alias "dpanda.localhost"
  ip-address 127.0.0.1
exit
host-alias "dpanda.xml.mgmt"
  ip-address 127.0.0.1
exit
EOF

projectDir="$(dirname "$PWD")"

#List all project directories
find "$projectDir" -type d -not -path "$projectDir/build*" -not -path "$projectDir/.git*" -not -path "$projectDir" -not -path "$projectDir/local" -not -path "$projectDir/local/dpanda" -not -path "$projectDir/config*" > $LOCALDIRS
sed -i -e "s|$projectDir/||" $LOCALDIRS
sed -i -e 's|/|:///|' $LOCALDIRS
sed -e "s|^|mkdir |" $LOCALDIRS >> $COMMANDS

#Creating the copy commands for all files
scpLocalAddress="copy -f scp://$USER:$localPassword@$localAddress/"

#List all project files excluding unnecessary files
find "$projectDir" -type f -not -path "$projectDir/build*" -not -path "$projectDir/.git*" -not -path "$projectDir/config*" -not -path "$projectDir/*.md" -not -path "$projectDir/*.txt" > $LOCALFILES

#Create a list of the desired remote files on DataPower
sed -e "s|$projectDir/||" $LOCALFILES > $REMOTEFILES
sed -i -e 's|/|:///|' $REMOTEFILES

#Append the copy command
sed -i -e "s|^|$scpLocalAddress|" $LOCALFILES

#Merge the files and append them to the commands file
paste -d" " localFiles.txt $REMOTEFILES >> $COMMANDS

rm $LOCALFILES $REMOTEFILES $LOCALDIRS

cat << EOF >> $COMMANDS
exit
switch domain dpanda
config
crypto
keygen CN dpanda-gui rsa 2048 gen-sscert days 3650
exit
EOF

echo "copy -f scp://$USER:$localPassword@$localAddress/$projectDir/config/dpanda/dpanda.cfg temporary:///dpanda.cfg" >> $COMMANDS
echo "exec temporary:///dpanda.cfgdp/index.html" >> $COMMANDS


ssh -T $dpAddress < $COMMANDS  > $OUTPUT

rm $COMMANDS
