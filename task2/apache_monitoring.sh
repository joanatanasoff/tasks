#!/bin/bash

# Checking if Apache2 is running
if systemctl status apache2 | grep -q 'active (running)'; then
    echo "Apache2 is running."
else
    echo "Apache2 is not running. Attempting to restart..."
    # Restarting Apache2 service
    systemctl restart apache2
    
    # Check if the restart was successful
    if systemctl status apache2 | grep -q 'active (running)'; then
        echo "Apache2 restarted successfully."
    else
        echo "Failed to restart Apache2. Check logs for errors."
    fi
fi
