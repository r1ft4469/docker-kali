FROM kalilinux/kali-rolling:latest

ARG BUILD_DATE
ARG VCS_REF
ARG DEPENDENCY_BUSTER

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/r1ft4469/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
	  
# RUN echo $DEPENDENCY_BUSTER > /dev/null

RUN apt update \
 && apt upgrade -y \
 && apt install -y postgresql metasploit-framework neovim tmux nmap sqlmap apache2 beef-xss \
 && apt clean
	
#RUN apt-get install -y --no-install-recommends \
#	neovim nmap sqlmap apache2 netcat ftp \
#	beef-xss ruby sed tmux libsqlite3-dev \
# && apt clean
	
#RUN apt-get install -y --no-install-recommends \
#	postgresql metasploit-framework \
 #&& apt clean

# RUN gem install wirble bundler \
 #&& mkdir /pentest

## RUN msfdb init

# RUN git clone https://github.com/danielmiessler/SecLists /pentest/seclists --depth 1 \
 #&& rm -rf /pentest/seclists/.git \
# && git clone https://github.com/FireFart/msfpayloadgenerator /pentest/msfpayloadgenerator --depth 1 \
# && rm -rf /pentest/msfpayloadgenerator/.git \
# && wget https://github.com/Charliedean/NetcatUP/raw/master/netcatup.sh -O /bin/netcatup.sh

COPY bin/* /usr/local/bin/

COPY scripts/* /root/.msf4/

# COPY share /pentest/share

# EXPOSE 80 443 4444 4433 4469

# WORKDIR /pentest/Desktop
