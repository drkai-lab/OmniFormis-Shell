#!/bin/bash
LOG_FILE="/tmp/qs_lens_debug.log"
echo "======================================" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting HTML Injection Google Lens script" >> "$LOG_FILE"

SCR_NAME=$1
IMAGE="/tmp/qs_lens_${SCR_NAME}.png"
if [ ! -f "$IMAGE" ]; then
    # Fallback in case screen name wasn't passed or fallback logic
    IMAGE="/tmp/qs_lens.png"
fi
if [ ! -f "$IMAGE" ]; then
    echo "ERROR: Image $IMAGE does not exist!" >> "$LOG_FILE"
    exit 1
fi
echo "Found image: $IMAGE" >> "$LOG_FILE"

# 1. Convert the image to a base64 string
B64_IMAGE=$(base64 -w 0 "$IMAGE")
HTML_FILE="/tmp/lens_upload.html"

# 2. Generate a local HTML file that handles the upload natively
cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html>
<head>
    <title>Google Lens Search</title>
    <style>
        body { 
            background: #11111b; 
            color: #cdd6f4; 
            font-family: sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
        }
        .spinner { 
            border: 4px solid rgba(255,255,255,0.1); 
            width: 40px; 
            height: 40px; 
            border-radius: 50%; 
            border-left-color: #89b4fa; 
            animation: spin 1s linear infinite; 
            margin: 0 auto 20px; 
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div style="text-align: center;">
        <div class="spinner"></div>
        <div>Uploading to Google Lens...</div>
    </div>

    <!-- Hidden form pointing directly to Lens -->
    <form id="lensForm" action="https://lens.google.com/v3/upload?ep=subb" method="POST" enctype="multipart/form-data">
        <input type="file" id="fileInput" name="encoded_image" style="display: none;">
    </form>

    <script>
        const b64 = "${B64_IMAGE}";
        
        // Convert the base64 string back into a binary File object
        fetch("data:image/png;base64," + b64)
            .then(res => res.blob())
            .then(blob => {
                const file = new File([blob], "image.png", { type: "image/png" });
                
                // Use DataTransfer to programmatically attach the file to the hidden input
                const dt = new DataTransfer();
                dt.items.add(file);
                document.getElementById('fileInput').files = dt.files;
                
                // Submit the form
                document.getElementById('lensForm').submit();
            })
            .catch(err => {
                document.body.innerHTML = "Upload preparation failed: " + err;
            });
    </script>
</body>
</html>
EOF

echo "HTML generated. Launching browser..." >> "$LOG_FILE"

# 3. Open the file in the default browser
nohup xdg-open "$HTML_FILE" >/dev/null 2>&1 &

# 4. Clean up the HTML file after the browser has had time to load it
(sleep 3 && rm -f "$HTML_FILE") &

echo "Browser launched and cleanup scheduled." >> "$LOG_FILE"
