#!/usr/bin/env bash

[ ! -f ./secrets ] && \
  echo 'secrets file is missing!' && \
  exit 1

source ./secrets

# Exit if the RECORD6_IDS array has no elements
[ ${#RECORD4_IDS[@]} -eq 0 ] && \
  echo 'RECORD4_IDS are missing!' && \
  exit 1

# Exit if the RECORD6_IDS array has no elements
[ ${#RECORD6_IDS[@]} -eq 0 ] && \
  echo 'RECORD6_IDS are missing!' && \
  exit 1

#https://api.digitalocean.com/v2/domains/

# Function to check if the ACCESS_TOKEN is valid
check_credentials() {
  response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer ${ACCESS_TOKEN}" "https://api.digitalocean.com/v2/domains")
  if [ "$response" != "200" ]; then
    echo "Invalid credentials. Please check your ACCESS_TOKEN."
    exit 1
  fi
}

# Check credentials before proceeding
check_credentials


public_ip4=$(curl -4 ifconfig.me)
public_ip6=$(curl ifconfig.me)

echo "Processing IPv4 records..."

for ID4 in "${RECORD4_IDS[@]}"; do
  local_ip4=$(
    curl \
      --fail \
      --silent \
      -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      "https://api.digitalocean.com/v2/domains/${DOMAIN}/records/${ID}" | \
      grep -Eo '"data":".*?"' | \
      grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
  )


  # if the IPs are the same just exit
  if [ "$local_ip4" == "$public_ip4" ]; then
    echo "IP has not changed for record ${ID4}, skipping."
    continue
  fi


  echo "Updating DNS record ${ID4} with new IP address: ${public_ip4}"
  # --fail silently on server errors
  curl \
    --fail \
    --silent \
    --output /dev/null \
    -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d "{\"data\": \"${public_ip4}\"}" \
    "https://api.digitalocean.com/v2/domains/${DOMAIN}/records/${ID4}"


done

#ipv6 loop

echo "Processing IPv6 records..."

for ID6 in "${RECORD6_IDS[@]}"; do
  local_ip6=$(
    curl \
      --fail \
      --silent \
      -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      "https://api.digitalocean.com/v2/domains/${DOMAIN}/records/${ID6}" | \
      grep -Eo '"data":".*?"' | \
      grep -Eo '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
  )

 # if the IPs are the same just exit
  if [ "$local_ip6" == "$public_ip6" ]; then
    echo "IP has not changed for record ${ID6}, skipping."
    continue
  fi

 echo "Updating DNS record ${ID6} with new IP address: ${public_ip6}"
  # --fail silently on server errors
  curl \
    --fail \
    --silent \
    --output /dev/null \
    -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d "{\"data\": \"${public_ip6}\"}" \
    "https://api.digitalocean.com/v2/domains/${DOMAIN}/records/${ID6}"
done
