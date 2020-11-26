#!/usr/bin/expect -f

set prompt "#"

set MAC_ADDRS_IDENTIFIER "(\[0-9A-F]{2}\[:-]){5}(\[0-9A-F]{2})"

set timeout 5

spawn sudo bluetoothctl
sleep 2
expect -re $prompt
send "paired-devices\r"
expect -re $MAC_ADDRS_IDENTIFIER
set MAC_ADDR "$expect_out(0,string)"
expect -re $prompt 
send "remove $MAC_ADDR \r"
expect -re $prompt
send "exit\r"
exit 0
