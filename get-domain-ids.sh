#!/usr/bin/env bash

source ./secrets

read -p "Please enter the domain (e.g. example.com): " DOMAIN2
read -p "Please enter the submain (e.g. host.example.com): " SUBDOMAIN


response=$(curl \
  --silent \
  -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://api.digitalocean.com/v2/domains/$DOMAIN2/records?name=$SUBDOMAIN")

echo "$response" | grep -Po '"id":\d*|"type":"\w*"|"name":"\w*"|"data":".*?"'

#Use this line to see the raw output if the above doesn't work on your system:
#curl -X GET -H "Authorization: Bearer $ACCESS_TOKEN " "https://api.digitalocean.com/v2/domains/argentwolf.org/records?name=$SUBDOMAIN"
