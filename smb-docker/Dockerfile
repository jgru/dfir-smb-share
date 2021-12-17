FROM debian:buster-slim
MAINTAINER 6ru <j4n6ru@gmail.com>

# Install samba
RUN apt-get upgrade && \
    apt-get update && \
    apt-get -y install samba && \
    apt-get -y install cifs-utils && \
    addgroup smb && \
    useradd -G smb smbuser

# Copy smb.conf (will be bind mounted late, however)
COPY /etc/samba/smb.conf /etc/samba/smb.conf
# Create the directories for the shares
RUN mkdir /evidence
RUN mkdir /tools

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=60s --timeout=15s \
	    CMD smbclient -L \\localhost -U % -m SMB3

VOLUME ["/evidence", "/tools", "/etc"]

ENTRYPOINT service smbd start && tail -F /var/log/samba/log.smbd
