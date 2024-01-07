#!/bin/bash
set -e

# Allow to run complementary processes or to enter the container without
# running this init script.
if [ "$1" == '/usr/sbin/sshd' ]; then

  # Ensure time is in sync with host
  # see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
  if [ -n ${TZ} ] && [ -f /usr/share/zoneinfo/${TZ} ]; then
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
  fi

  # Regenerate keys
  if [ ! -f "/etc/ssh/keys/ssh_host_rsa_key" ]; then
    ssh-keygen -f /etc/ssh/keys/ssh_host_rsa_key -N '' -t rsa
  fi
  if [ ! -f "/etc/ssh/keys/ssh_host_dsa_key" ]; then
    ssh-keygen -f /etc/ssh/keys/ssh_host_dsa_key -N '' -t dsa
  fi
  if [ ! -f "/etc/ssh/keys/ssh_host_ecdsa_key" ]; then
    ssh-keygen -f /etc/ssh/keys/ssh_host_ecdsa_key -N '' -t ecdsa
  fi

  # Check if a script is available in /docker-entrypoint.d and source it
  # You can use it for example to create additional sftp users
  for f in /docker-entrypoint.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *)     echo "$0: ignoring $f" ;;
    esac
  done

fi

exec "$@"


