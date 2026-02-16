# CamPhish v2.0 - Advanced Camera & Location Phishing Tool

CamPhish is a powerful penetration testing tool designed to capture camera shots and GPS location from targets via a simple phishing link. It hosts a fake website locally and uses tunneling services like Ngrok or CloudFlare to make it accessible over the internet.

![CamPhish Banner](https://techchip.net/wp-content/uploads/2020/04/camphish.jpg)

## 🚀 Features
- **Front Camera Capture**: Take stealthy shots from the target's phone or webcam.
- **GPS Location Tracking**: Integrated GPS capture with Google Maps links.
- **Device & Cookie Grabbing**: Captures detailed device info and browser cookies.
- **Automated Templates**: 
  - Festival Wishing
  - Live YouTube TV
  - Online Meeting (Pro Style)
- **Multi-Platform Support**: Optimized for Kali Linux, Termux, and Windows.

## 🛠️ Installation (Kali Linux / Ubuntu / Debian)

First, ensure you have the required dependencies:

```bash
sudo apt-get update
sudo apt-get install -y php wget unzip curl
```

Clone the repository and run the script:

```bash
git clone https://github.com/YOUR_USERNAME/CamPhish
cd CamPhish
chmod +x camphish.sh
bash camphish.sh
```

## 🌐 How to Use
1. Run the script: `bash camphish.sh`
2. Choose a tunnel service (Ngrok or CloudFlare).
3. Select a phishing template.
4. Send the generated link to the target.
5. Watch the captured data in the terminal or use the `monitor.php` dashboard.

### 🛰️ Live Monitoring
You can view all captured data in real-time by opening the local monitor:
`http://127.0.0.1:3333/monitor.php`

## ⚖️ Disclaimer
This tool is created for educational and ethical penetration testing purposes only. Unauthorized use of this tool for illegal activities is strictly prohibited. The developer is not responsible for any misuse.

---
**Author**: TechChip | **Modified by**: [Your Nickname]
**YouTube**: [TechChip Channel](http://youtube.com/techchipnet)
