FROM ubuntu:xenial
MAINTAINER Sol&TIC <serveur@soletic.org>

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV TZ "Asia/Manila"
ENV DEBIAN_FRONTEND noninteractive

# Allow restart/stop service when we upgrade (see http://askubuntu.com/questions/365911/why-the-services-do-not-start-at-installation)
RUN sed -ri -e "s/101/0/" /usr/sbin/policy-rc.d

# Local
RUN apt-get update
RUN apt-get install -y supervisor unzip locales psmisc cron
RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && DEBIAN_FRONTEND=noninteractive && export DEBIAN_FRONTEND

ADD ubuntu-run.sh /ubuntu-run.sh
RUN chmod u+x /ubuntu-run.sh
ADD ubuntu-setup.conf /etc/supervisor/conf.d/ubuntu-setup.conf

RUN mkdir -p /root/scripts
ADD ubuntu.start.sh /root/scripts/ubuntu.start.sh
RUN chmod u+x /root/scripts/ubuntu.start.sh
COPY crontab /etc/crontab

CMD ["/ubuntu-run.sh", "-D", "FOREGROUND"]

#ssh-specific --------------------------

RUN apt-get update && \
  apt-get install -y openssh-server && \
  apt-get install -y pwgen git curl wget

ENV WORKER_NAME ""
ENV WORKER_UID 10001

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

VOLUME ["/var/log", "/home"]

ADD supervisor-sshd.conf /etc/supervisor/conf.d/supervisor-sshd.conf
ADD sshd-run.sh /root/scripts/sshd.sh
RUN chmod 755 /root/scripts/*.sh

EXPOSE 22

#chroot-specific --------------------------

ENV CHROOT_INSTALL_DIR /chroot
# Path to directory where user directories are stored
ENV CHROOT_USERS_HOME_DIR /home
# Absolute dir path from a home user dir that will be mounted as home dir in the chroot environment
ENV CHROOT_USER_HOME_BASEPATH ""

ADD sshd_config_addons /etc/ssh/sshd_config_addons
RUN groupadd sshusers
RUN sed -ri -e 's/^Subsystem sftp.*/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config
RUN cat /etc/ssh/sshd_config_addons >> /etc/ssh/sshd_config

RUN mkdir -p /chroot/plugins

# Bin utils
ADD l2chroot.sh /l2chroot.sh
ADD chroot.sh /chroot.sh
ADD install_bin.sh /install_bin.sh
ADD install_bin.sh /install_bin-add.sh
RUN chmod 755 /*.sh

# Start program
ADD supervisor-sshchrooted.conf /etc/supervisor/conf.d/supervisor-sshchrooted.conf
ADD ssh-chrooted-setup.sh /root/scripts/ssh-chrooted-setup.sh
RUN chmod 755 /root/scripts/*.sh
