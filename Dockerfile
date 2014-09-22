FROM sdhibit/rpi-raspbian
MAINTAINER Steve Hibit <sdhibit@gmail.com>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
 apt-get update && \
 apt-get install -qy supervisor wget unzip ffmpeg lame locales && \
 apt-get clean

#Download & Install Java 8 arm hard float from Oracle
RUN mkdir -p /opt/jdk1.8.0 && \
 wget -O /tmp/jdk1.8.0.tar.gz \
 --no-cookies --no-check-certificate \
 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
 "http://download.oracle.com/otn-pub/java/jdk/8u6-b23/jdk-8u6-linux-arm-vfp-hflt.tar.gz" && \
 tar zxvf /tmp/jdk1.8.0.tar.gz -C /opt/jdk1.8.0 --strip-components 1 && \
 rm /tmp/jdk1.8.0.tar.gz

RUN update-alternatives --install "/usr/bin/java" "java" "/opt/jdk1.8.0/bin/java" 1 && \
 update-alternatives --set java /opt/jdk1.8.0/bin/java

ENV JAVA_HOME /opt/jdk1.8.0
ENV PATH $PATH:$JAVA_HOME/bin

#Download & Install Subsonic Standalone
RUN mkdir -p /usr/share/subsonic && \ 
 wget -P /tmp/ "http://sourceforge.net/projects/subsonic/files/subsonic/4.9/subsonic-4.9-standalone.tar.gz" && \
 tar zxvf /tmp/subsonic-4.9-standalone.tar.gz -C /usr/share/subsonic && \
 rm -rf /tmp/subsonic-4.9-standalone.tar.gz

#RUN ln /var/subsonic/transcode/ffmpeg /var/subsonic/transcode/lame /usr/local/bin

# Don't fork to the background
RUN sed -i "s/ > \${LOG} 2>&1 &//" /usr/share/subsonic/subsonic.sh

ADD ./supervisor/supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 4040

# Activate subsonic under supervisor so the Docker container is persisted
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf"]