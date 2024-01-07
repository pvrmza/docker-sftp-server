#!/bin/bash

# Author: Pablo Vargas <pablo@pampa.cloud>
# License: GPLv2

if [ -f "/config/users.yaml" ]; then
    infile=/config/users.yaml

    num_users=$(yq eval '.users | length' "$infile")

    for ((i=0; i<num_users; i++)); do
      username=$(yq eval ".users[$i].username" "$infile")

      if [ $(yq eval ".users[$i].uid | length" "$infile") -gt 0 ]; then
        uid=$(yq eval ".users[$i].uid" "$infile")        
        UID="-u $uid"
      else
        UID=""      
      fi

      if [ $(yq eval ".users[$i].homedirectory | length" "$infile") -gt 0 ]; then
        homedirectory=$(yq eval ".users[$i].homedirectory" "$infile")       
        HOMEDIR="-d $homedirectory"
      else
        HOMEDIR=""      
      fi

      if ! id "$username" &>/dev/null; then
        useradd $UID $HOMEDIR -M -G sftp -s /bin/false $username
        # Print a message indicating the user has been created
        echo "User '$username' created successfully."
      else 
        usermod $UID $HOMEDIR -G sftp -a -s /bin/false $username
      fi

      uid=$(id -u $username)

      if [ $(yq eval ".users[$i].password | length" "$infile") -gt 0 ]; then
        password=$(yq eval ".users[$i].password" "$infile")
        echo "$username:$password" | chpasswd
        PASSWORDAUTH=""
      else
        usermod -p '*' "$username"  
        PASSWORDAUTH="PasswordAuthentication no"      
      fi

      if [ $(yq eval ".users[$i].umask | length" "$infile") -gt 0 ]; then
        umask=$(yq eval ".users[$i].umask" "$infile")        
        UMASK="-u $umask"
      else 
        UMASK=""
      fi

      if [ $(yq eval ".users[$i].chroot | length" "$infile") -gt 0 ]; then
        chroot=$(yq eval ".users[$i].chroot" "$infile")
        mkdir -p "$chroot/$username"
        chown "$username" "$chroot/$username" -R
        CHROOT="ChrootDirectory $chroot"
      else
        CHROOT=""
      fi

      if [ $(yq eval ".users[$i].sftpblackewq | length" "$infile") -gt 0 ]; then
        sftpblackewq=$(yq eval ".users[$i].sftpblackewq" "$infile")
        SFTPBLACKREQ="-P $sftpblackewq"
      else
        SFTPBLACKREQ=""
      fi

      mkdir -p "$homedirectory/.ssh"

      yq eval ".users[$i].ssh_public_keys" "$infile" | awk -F\" '{print $2}' > "$homedirectory/.ssh/authorized_keys"

      chmod 700 "$homedirectory" -R
      chmod 600 "$homedirectory/.ssh/authorized_keys"
      chown "$username" "$homedirectory" -R

      echo "Match User $username
        ForceCommand internal-sftp $UMASK $SFTPBLACKREQ
        $CHROOT
        $PASSWORDAUTH    
        " > /etc/ssh/sshd_config.d/${username}.conf

    done
fi
