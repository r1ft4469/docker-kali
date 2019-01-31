alias msfconsole='msf_start'

function msf_start() {
tmuxwindowname=$(tmux display-message -p '#W')
tmux rename-window -t${TMUX_PANE} "msf"
tmuxwindownamebuild=$(tmux display-message -p '#W')
while getopts d:n:p:hu option
do
	case "${option}" in
		d)
			desktopfolder=${OPTARG}
			;;
		n) 
			netiface=${OPTARG}
			hostip="ninjacloud.net"
			;;
		p) 
			exploitport=$OPTARG
			;;
		u)
			shellupgradeport=$OPTARG
			;;
		h)
			echo "msfconsole docker image start script help"
			echo "--------------------------------------------"
			echo "-d	<Desktop Folder>"
			echo "-n	<Network iface>"
			echo "-p	<Lisener Port>"
			echo "-u	<Shell Upgrade Port>"
			tmux rename-window -t${TMUX_PANE} $tmuxwindowname
			return 0
			;;
	esac
done

if [ -z $shellupgradeport ]; then
	shellupgradeport=4433
fi

tmuxwindownamebuild=$(echo $tmuxwindownamebuild)" (p="$(echo $exploitport)" u="$(echo $shellupgradeport)")"
tmux rename-window -t${TMUX_PANE} $tmuxwindownamebuild

# start bash ports forwarding and shared folders
msf="$(docker run -d -t \
	-p $exploitport:$exploitport \
	-p 80:80 \
	-p 3000:3000 \
	-p $shellupgradeport:$shellupgradeport \
	-p 443:443 \
	-v $desktopfolder:/pentest/Desktop \
	pennoser/production:latest /bin/bash)"

# setup msfconsole startup
docker exec -t $msf /bin/bash \
	-c "echo alias upgrade 'use post/multi/manage/shell_to_meterpreter LPORT=$shellupgradeport' >> /root/.msf4/msfconsole.rc"
docker exec -t $msf /bin/bash \
	-c "echo clear >> /root/.msf4/msfconsole.rc"
docker exec -t $msf /bin/bash \
	-c "echo set -g LHOST $hostip >> /root/.msf4/msfconsole.rc"

# setup Apache
docker exec -t $msf /bin/bash \
	-c "service apache2 start \
	 && chmod 600 /pentest/digitalocean.ini \
	 && chmod 600 /pentest/digitalocean.ini \
	 && certbot -n --apache -d ninjacloud.net -d www.ninjacloud.net --reinstall --redirect"

# run msfconsole
docker exec -ti $msf msf 

# cleanup
docker container stop $msf
docker container rm $msf
rm $desktopfolder/shell*
desktopfolder=''
netiface=''
hostip=''
exploitport=''
shellupgradeport=''
winpay=''
linpay=''
osxpay=''
tmux rename-window -t${TMUX_PANE} $tmuxwindowname
}

