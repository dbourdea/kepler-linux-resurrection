#!/bin/bash
# NVIDIA Kepler Thermal Guardrails - Amelia PRO V2
# HARDENED: Validates all inputs and handles driver resets gracefully.

MIN_TEMP=40
MAX_TEMP=80
MIN_FAN=30
MAX_FAN=100

export DISPLAY=:0
# Robust Xauth detection
export XAUTHORITY=$(ps aux | grep -m 1 "Xorg" | grep -oP '(?<=-auth )\S+' || find /run/user -name Xauthority | head -n 1)

while true; do
    # 1. Fetch Temperature with error handling
    RAW_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    
    # 2. Bullshit Check: Ensure TEMP is a valid integer
    if [[ "$RAW_TEMP" =~ ^[0-9]+$ ]]; then
        TEMP=$RAW_TEMP
        
        # 3. Enable manual fan control (idempotent)
        nvidia-settings -a "[gpu:0]/GPUFanControlState=1" > /dev/null 2>&1
        
        # 4. Calculate Speed
        if [ "$TEMP" -le "$MIN_TEMP" ]; then
            SPEED=$MIN_FAN
        elif [ "$TEMP" -ge "$MAX_TEMP" ]; then
            SPEED=$MAX_FAN
        else
            # Linear interpolation
            SPEED=$(( MIN_FAN + (TEMP - MIN_TEMP) * (MAX_FAN - MIN_FAN) / (MAX_TEMP - MIN_TEMP) ))
        fi
        
        # 5. Apply Speed
        nvidia-settings -a "[fan:0]/GPUTargetFanSpeed=$SPEED" > /dev/null 2>&1
    else
        echo "[WARNING] Invalid temp reading: '$RAW_TEMP'. Skipping iteration."
    fi
    
    sleep 5
done
