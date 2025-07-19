#!/usr/bin/env bash
#This script will pull ALL domain records for the specified domain in the *secrets* file
source ./secrets

response=$(curl \
  --silent \
  -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://api.digitalocean.com/v2/domains/$DOMAIN/records")

echo "$response" | grep -Po '"id":\d*|"type":"\w*"|"name":"\w*"|"data":".*?"'
