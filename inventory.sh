#!/bin/sh
#!/bin/sh
# solaris_audit.sh - basic local recon/info for Solaris
# test 

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

hr() { echo "------------------------------------------------------------"; }

echo "Solaris System Summary"
hr

# Hostname
echo "Hostname:"
hostname 2>/dev/null || uname -n
hr

# Users (local passwd)
echo "Local users (/etc/passwd):"
cut -d: -f1 /etc/passwd | sort
hr

# IP addresses (prefer ipadm, fallback to ifconfig)
echo "IP addresses (non-loopback):"
if command -v ipadm >/dev/null 2>&1; then
  # Prints address objects and addresses, filter out loopback and "0.0.0.0"
  ipadm show-addr -p -o ADDR 2>/dev/null | \
    grep -v '^127\.' | grep -v '^0\.0\.0\.0' | grep -v '^::1' | sort -u
else
  # Solaris ifconfig output varies; this grabs inet/inet6 lines
  ifconfig -a 2>/dev/null | \
    awk '
      $1=="inet"  {print $2}
      $1=="inet6" {print $2}
    ' | grep -v '^127\.' | grep -v '^::1' | sort -u
fi
hr

# MAC addresses (prefer dladm, fallback to ifconfig)
echo "MAC addresses:"
if command -v dladm >/dev/null 2>&1; then
  # Get link + MAC. Some systems use show-phys, some show-link.
  (dladm show-phys -m 2>/dev/null || dladm show-link -p -o LINK 2>/dev/null) | \
    awk '
      # For show-phys -m, MAC is usually in a "MACADDR" column; just match xx:xx:xx:xx:xx:xx
      {
        for (i=1;i<=NF;i++) {
          if ($i ~ /^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$/) {
            print $1 ": " $i
            next
          }
        }
      }
    ' | sort -u
else
  # ifconfig on Solaris often includes "ether xx:xx:xx:xx:xx:xx"
  ifconfig -a 2>/dev/null | \
    awk '
      $1 ~ /^[a-z0-9]+:/ {iface=$1; sub(/:$/, "", iface)}
      $1=="ether" {print iface ": " $2}
    ' | sort -u
fi
hr

# Open/listening ports (TCP and UDP)
echo "Open/listening ports:"
if netstat -an >/dev/null 2>&1; then
  # TCP LISTEN + UDP sockets.
  # Output is different across versions; these patterns are the most portable.
  echo "TCP (LISTEN):"
  netstat -an -P tcp 2>/dev/null | awk '
    /LISTEN/ {print}
  ' || netstat -an 2>/dev/null | awk '/LISTEN/ {print}'
  echo
  echo "UDP:"
  netstat -an -P udp 2>/dev/null | awk '
    # UDP often has no LISTEN word; just print udp lines with a local address
    {print}
  ' || netstat -an 2>/dev/null | awk '/udp/ {print}'
else
  echo "netstat not available."
fi
hr

# Optional: quick hint if you want process-to-port mapping
echo "Note:"
echo "  Mapping ports -> processes on Solaris can require privileges."
echo "  If you want that, tell me your Solaris version (10/11/illumos) and whether you have sudo/root."