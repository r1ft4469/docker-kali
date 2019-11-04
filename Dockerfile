FROM kalilinux/kali-rolling:latest

ARG BUILD_DATE
ARG VCS_REF
ARG DEPENDENCY_BUSTER

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/r1ft4469/docker-kali" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"
	  
RUN apt update \
 && apt upgrade -y \
 && apt install -y postgresql metasploit-framework neovim tmux nmap sqlmap apache2 beef-xss \
 && apt clean
	
COPY bin/* /usr/local/bin/

COPY scripts/* /root/.msf4/

COPY tmux.conf /root/.tmux.conf
#COPY xresource-powerline.tmuxtheme /root/.xresource-powerline.tmuxtheme
#COPY Xresources /root/.Xresources

RUN ln -s /usr/share/metasploit-framework/config/database.yml /root/.msf4/

WORKDIR /root
