FROM alpine
MAINTAINER Pablo Vargas <pablo@pampa.cloud>

# shadow is required for usermod
# tzdata for time syncing
# bash for entrypoint script
RUN apk add --no-cache openssh bash shadow tzdata yq

# Ensure key creation
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key ;\
    mkdir -p /docker-entrypoint.d ; \
    mkdir -p /etc/ssh/sshd_config.d 

ADD files/docker-entrypoint.sh /
ADD files/sshd_config /etc/ssh/sshd_config
ADD files/alta.sh /docker-entrypoint.d/alta.sh

RUN chmod +x /docker-entrypoint.sh ; \
    addgroup sftp 

# Default environment variables
ENV TZ="America/Argentina/Mendoza" \
    LANG="C.UTF-8"

EXPOSE 22
ENTRYPOINT [ "/docker-entrypoint.sh" ]

# RUN SSH in no daemon and expose errors to stdout
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
