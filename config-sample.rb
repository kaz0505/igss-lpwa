# coding: utf-8
#
# This file is for IGSS-LPWA configuration
#
# configuration file name is 'config.rb'
# you should copy/rename this file 'config-sample.rb' to 'config.rb'
# and edit config.rb
#
# area name, which is lpwa network name for specific region
# 
#
$lpwa_area_name = "demo-kanda"


# serial port information
# 
#
$serial_port = "/dev/ttyACM0"
$serial_bps = 115200

#
# server URL for API access
# if you are using local server, use localhost:4567
# if you are using clould server, use ip address
#
# $server_url = "http://localhost:4567/"
$server_url = "http://igss.ddns.net:4567/"

#
# API key
#
$security_key = "aabbccddeeffgghh001122334455"

#
# API access cycle
# NOTE: this cycle is closely related to network latency
#   local server 1 sec
#   remote server via LAN 1 sec
#   remote server via WAN 5 secs 
#   remote server via 3G/LTE 10 to 30 secs
#
$api_access_cycle = 1

