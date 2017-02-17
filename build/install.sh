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
EOF

projectDir="$(dirname "$PWD")"
#List all project directories
find "$projectDir" -type d -not -path "$projectDir/build*" -not -path "$projectDir/.git*" -not -path "$projectDir" -not -path "$projectDir/local" -not -path "$projectDir/config*" > $LOCALDIRS
sed -i -e "s|$projectDir/||" $LOCALDIRS
sed -i -e 's|/|:///|' $LOCALDIRS
sed -e "s|^|mkdir |" $LOCALDIRS >> $COMMANDS

#Creating the copy commands for all files
scpLocalAddress="copy scp://$USER:$localPassword@$localAddress/"

#List all project files excluding unnecessary files
find "$projectDir" -type f -not -path "$projectDir/build*" -not -path "$projectDir/.git*" -not -path "$projectDir/config*" > $LOCALFILES

#Create a list of the desired remote files on DataPower
sed -e "s|$projectDir/||" $LOCALFILES > $REMOTEFILES
sed -i -e 's|/|:///|' $REMOTEFILES

#Append the copy command
sed -i -e "s|^|$scpLocalAddress|" $LOCALFILES

#Merge the files and append them to the commands file
paste -d" " localFiles.txt $REMOTEFILES >> $COMMANDS

rm $LOCALFILES $REMOTEFILES $LOCALDIRS

ssh -T $dpAddress < $COMMANDS  > $OUTPUT
