#!/bin/bash

# Assumes a key-value'ish pair
# $1 is the key and $2 is the value
function update_or_add {
  TORRC=/etc/tor/torrc
  FINDINFILE=$(grep -e "^$1.*$" $TORRC)

  echo "Adding $1 $2 to Torrc"

  # Append if missing.
  # Update if exist.
  if [ -z "$FINDINFILE" ]; then
    echo "$1 $2" >> $TORRC
  else
    sed -i "s/^$1.*/$1 $2/g" $TORRC
  fi
}

# Default communcation port
update_or_add 'ORPort' '9001'
update_or_add 'DirPort' '9030'

# Disable Socks connections
update_or_add  'SocksPort' '0'

# Reject all exits. Only relay.
update_or_add 'ExitPolicy' 'reject *:*'

# Set $Nickname to the node nickname
if [ -n "$Nickname" ]; then
  update_or_add 'Nickname' "$Nickname"
else
  update_or_add 'Nickname' 'DockerTorRelay'
fi

# Set $ContactInfo to your contact info
if [ -n "$ContactInfo" ]; then
  update_or_add 'ContactInfo' "$ContactInfo"
else
  update_or_add 'ContactInfo' 'Anonymous'
fi

## Set monthly bandwidth limit.
if [ -n "$AccountingMax" ]; then
  # Start the count on the first after midnight
  update_or_add 'AccountingStart' 'month 1 00:01'
  update_or_add 'AccountingMax' "$AccountingMax"
fi

# Set bandwidth limit and burst
if [ -n "$RelayBandwidthRate" ]; then
  update_or_add 'RelayBandwidthRate' "$RelayBandwidthRate"
fi
if [ -n "$RelayBandwidthBurst" ]; then
  update_or_add 'RelayBandwidthBurst' "$RelayBandwidthBurst"
fi

# Set Family if specified
if [ -n "$MyFamily" ]; then
  update_or_add 'MyFamily' "$MyFamily"
fi

# Set Address if specified
if [ -n "$Address" ]; then
  update_or_add 'Address' "$Address"
fi

# Start Tor
chown -R tor:tor /home/tor
sudo -u tor -H /usr/sbin/tor -f /etc/tor/torrc
