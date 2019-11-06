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
 && apt clean

RUN apt update \
  && apt install -y --no-install-recommends \
	postgresql \
  && apt clean

RUN apt update \
  && apt install -y --no-install-recommends \
  	metasploit-framework \
  && apt clean 

RUN apt update \
  && apt install -y --no-install-recommends \ 
	tmux nmap \
  && apt clean

RUN apt update \
  && apt install -y --no-install-recommends \
 	sqlmap \
  && apt clean

RUN apt update \
  && apt install -y --no-install-recommends \
  	apache2 \
  && apt clean

RUN apt update \
  && apt install -y --no-install-recommends \
  	beef-xss \
  && apt clean

COPY configs/init.vim /root/.config/nvim/init.vim

RUN apt update \
  && apt install -y neovim \
  && apt clean \
  && curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && nvim --headless +PlugInstall +qa


COPY bin/* /usr/local/bin/

COPY scripts/* /root/.msf4/

RUN ln -s /usr/share/metasploit-framework/config/database.yml /root/.msf4/

COPY configs/tmux.conf /root/.tmux.conf

WORKDIR /root
