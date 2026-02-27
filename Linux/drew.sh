#!/bin/bash
# =============================================================================
# Cleanup script for Linux C2 client
# Targets ONLY the exact indicators provided:
#   • Binary   : /lib/systemd/systemd-boot-system-key
#   • Service  : /lib/systemd/system/systemd-boot-system-key.service
#   • Service name: systemd-boot-system-key
#
# Must be run as root (sudo).
# =============================================================================

set -o pipefail

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN}Starting academic cleanup of simulated Linux C2 client${NC}"
echo -e "${CYAN}Target indicators:${NC}"
echo -e "${CYAN}   • Binary   : /lib/systemd/systemd-boot-system-key${NC}"
echo -e "${CYAN}   • Service  : /lib/systemd/system/systemd-boot-system-key.service${NC}"
echo -e "${CYAN}   • Service name : systemd-boot-system-key${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}✗ This script must be run as root (sudo).${NC}"
    exit 1
fi

# ------------------------------------------------------------------
# 1. Kill any running processes matching the binary name
# ------------------------------------------------------------------
echo -e "${YELLOW}[1/4] Checking for running processes (systemd-boot-system-key)...${NC}"

if pgrep -f "systemd-boot-system-key" > /dev/null; then
    pkill -f "systemd-boot-system-key" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ Killed all matching processes${NC}"
    else
        echo -e "${RED}   ✗ Failed to kill processes${NC}"
    fi
else
    echo -e "${YELLOW}   No running processes found${NC}"
fi

# ------------------------------------------------------------------
# 2. Stop and disable the systemd service
# ------------------------------------------------------------------
SERVICE_NAME="systemd-boot-system-key"

echo -e "\n${YELLOW}[2/4] Stopping and disabling systemd service '${SERVICE_NAME}'...${NC}"

systemctl stop "${SERVICE_NAME}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ Service stopped${NC}"
else
    echo -e "${YELLOW}   Service was not running${NC}"
fi

systemctl disable "${SERVICE_NAME}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ Service disabled${NC}"
else
    echo -e "${YELLOW}   Service was not enabled${NC}"
fi

# ------------------------------------------------------------------
# 3. Remove the service file
# ------------------------------------------------------------------
SERVICE_FILE="/lib/systemd/system/systemd-boot-system-key.service"

echo -e "\n${YELLOW}[3/4] Removing service file...${NC}"
echo -e "${YELLOW}   Target: ${SERVICE_FILE}${NC}"

if [ -f "${SERVICE_FILE}" ]; then
    rm -f "${SERVICE_FILE}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ Successfully deleted ${SERVICE_FILE}${NC}"
    else
        echo -e "${RED}   ✗ Failed to delete service file${NC}"
    fi
else
    echo -e "${YELLOW}   Service file not present${NC}"
fi

# ------------------------------------------------------------------
# 4. Remove the binary
# ------------------------------------------------------------------
BINARY_PATH="/lib/systemd/systemd-boot-system-key"

echo -e "\n${YELLOW}[4/4] Removing binary...${NC}"
echo -e "${YELLOW}   Target: ${BINARY_PATH}${NC}"

if [ -f "${BINARY_PATH}" ]; then
    rm -f "${BINARY_PATH}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ Successfully deleted ${BINARY_PATH}${NC}"
    else
        echo -e "${RED}   ✗ Failed to delete binary${NC}"
    fi
else
    echo -e "${YELLOW}   Binary not present at target path${NC}"
fi

# ------------------------------------------------------------------
# Final systemd reload
# ------------------------------------------------------------------
echo -e "\n${YELLOW}Reloading systemd daemon...${NC}"
systemctl daemon-reload
echo -e "${GREEN}   ✓ systemd reloaded${NC}"

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
echo -e "\n${CYAN}===================================================================${NC}"
echo -e "${GREEN}Cleanup completed.${NC}"
echo -e "${CYAN}Only the exact academic indicators were targeted.${NC}"
echo -e "${CYAN}Reboot recommended to clear any remaining in-memory artifacts.${NC}"
echo -e "${CYAN}===================================================================${NC}"

exit 0
