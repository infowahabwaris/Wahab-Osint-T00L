#!/bin/bash
# CamPhish Diagnostic Tool
# Run this to find the exact problem

echo "=== CamPhish Diagnostic Test ==="
echo ""

echo "[1] Checking if cloudflared exists..."
if [[ -f "cloudflared" ]]; then
    echo "✓ File exists"
    ls -lh cloudflared
else
    echo "✗ cloudflared not found!"
    exit 1
fi

echo ""
echo "[2] Checking permissions..."
if [[ -x "cloudflared" ]]; then
    echo "✓ File is executable"
else
    echo "✗ File is NOT executable. Fixing..."
    chmod +x cloudflared
fi

echo ""
echo "[3] Testing binary..."
./cloudflared --version
if [[ $? -eq 0 ]]; then
    echo "✓ Binary works"
else
    echo "✗ Binary is corrupt or incompatible"
    echo "Downloading fresh binary..."
    rm -f cloudflared
    wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    chmod +x cloudflared
    ./cloudflared --version
fi

echo ""
echo "[4] Testing PHP server..."
pkill -f "php -S 127.0.0.1:3333" 2>/dev/null
php -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 2
if curl -s http://127.0.0.1:3333 > /dev/null; then
    echo "✓ PHP server is running"
else
    echo "✗ PHP server failed to start"
fi

echo ""
echo "[5] Testing cloudflared tunnel (10 seconds)..."
rm -f test.log
./cloudflared tunnel -url http://127.0.0.1:3333 --logfile test.log &
TUNNEL_PID=$!
sleep 10

echo ""
echo "[6] Checking log output..."
if [[ -s test.log ]]; then
    echo "✓ Log file has content:"
    cat test.log
else
    echo "✗ Log file is empty!"
    echo "Checking if cloudflared is running..."
    ps aux | grep cloudflared | grep -v grep
fi

echo ""
echo "[7] Cleanup..."
kill $TUNNEL_PID 2>/dev/null
pkill -f cloudflared 2>/dev/null
pkill -f "php -S 127.0.0.1:3333" 2>/dev/null

echo ""
echo "=== Diagnostic Complete ==="
echo "Please copy the ENTIRE output above and send it."
