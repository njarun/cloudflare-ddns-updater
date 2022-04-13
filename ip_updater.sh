#!/bin/bash

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Used to provide DDNS service for my home

## Cloudflare authentication details
## keep these private, also make sure you have included all required zones.
cloudflare_auth_email=your_login_email@example.com
cloudflare_auth_key=your_auth_key

# An associated array to store Cloudflare zone/domain name value pairs
# dns records is the A record which will be updated
declare -A zoneMap
zoneMap[domain1.com]="domain1.com *.domain1.com www.domain1.com sub1.domain1.com sub2.domain1.com"
zoneMap[domain2.com]="domain2.com *.domain2.com www.domain2.com sub1.domain2.com sub2.domain2.com"

printf "\n:::::::::::::: CloudFlare DNS Ip Update START :::::::::::::::\n\n"

now="$(date)"
printf "Operation Start: %s" "$now"

# Get the current external IP address
ip=$(curl -s -X GET https://checkip.amazonaws.com)

echo
echo
echo "Public IP is $ip"

# iterate over the zones
for zone in "${!zoneMap[@]}"
do

  echo

  dns_records=(${zoneMap[$zone]})

  # get the zone id for the requested zone
  zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
    -H "X-Auth-Email: $cloudflare_auth_email" \
    -H "Authorization: Bearer $cloudflare_auth_key" \
    -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

  echo "Zone id for $zone is $zone_id"

  # loop dns records
  for dns_record in ${dns_records[@]}
  do

    # get the dns record id
    dns_entry_val=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$dns_record" \
      -H "X-Auth-Email: $cloudflare_auth_email" \
      -H "Authorization: Bearer $cloudflare_auth_key" \
      -H "Content-Type: application/json")

    dns_record_id=$(jq -r '{"result"}[] | .[0] | .id' <<<"$dns_entry_val")
    dns_record_a_ip=$(jq -r '{"result"}[] | .[0] | .content' <<<"$dns_entry_val")

    echo
    echo "DNS record id for $dns_record is $dns_record_id and ip is $dns_record_a_ip"

    #check is host need to update
    if [ "$dns_record_a_ip" == "$ip" ]; then
      echo "DNS ip up to date, no update needed"
      continue
    fi

    #if here, the dns record needs updating
    # update the record
    update_result=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_id" \
      -H "X-Auth-Email: $cloudflare_auth_email" \
      -H "Authorization: Bearer $cloudflare_auth_key" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$dns_record\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":true}" | jq -r '{"success"} | .success')

    echo "DNS update is success -> $update_result"

  done

done

now="$(date)"
printf "\nOperation End: %s" "$now"

printf "\n\n:::::::::::::: CloudFlare DNS Ip Update END :::::::::::::::\n\n"

echo
