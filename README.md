SFTP server for docker
======================

## Description

This is a lightweight SFTP server in a docker container.

This image provides:
 - an alpine base image
 - SSH server
 - User creation based on env variable
 - Home directory based on env variable
 - Automatic UID detection based on home permissions
 - Ability to run in chroot
 - Extensibility through additional sh scripts (more users creation, tweak...)


## How to use

### Provided example

A full example is provided in the [docker-compose file](https://github.com/pvrmza/docker-sshd-server/blob/master/docker-compose.yml)

    
    git clone https://github.com/pvrmza/docker-sshd-server.git
    cd docker-sshd-server
    cp users.yaml.example users.yaml
    docker-compose up

### Generic example

    version: '2'

    services:
      sshd:
        image: pvrmza/docker-sftp-server:latest
        env_file:
          - .env
        cap_add:
          # Required if you want to chroot
          - SYS_ADMIN
        security_opt:
          # Required if you want to chroot
          - apparmor:unconfined
        ports:
          - 2222:22
        volumes:
          #- ./users.yaml:/config/users.yaml
          - ./vol/keys:/etc/ssh/keys/


### Configuration

### users.yaml example

``` 
    users:
    - username: username1
      homedirectory: /home/username1
      password: ChangeIT2024!
      ssh_public_keys:
        - "ssh-rsa your ssh public key 1"
        - "ssh-rsa your ssh public key 2"

    - username: username2
      uid: 1002
      homedirectory: /home/username2
      umask: 0222
      chroot: /data1
      sftpblackewq: remove,rmdir,mkdir,symlink,rename
      ssh_public_keys:
        - "ssh-rsa your ssh public key 1"
```


## Disclaimer

Besides the usual disclaimer in the license, we want to specifically emphasize that the authors, and any organizations the authors are associated with, can not be held responsible for data-loss caused by possible malfunctions of Docker Magic Sync.

## License

[GPLv2](http://www.fsf.org/licensing/licenses/info/GPLv2.html) or any later GPL version.
