#!/usr/bin/expect -f

set i 0;

foreach el "$argv" { set "exp_[incr i]" "$el" }

#Override the execution timeout ...
set timeout 60

#The target expected command to execute
spawn npm login [lindex $argv 3] [lindex $argv 4]

match_max 100000

expect "Username"
send "$exp_1\r"

expect "Password"
send "$exp_2\r"

expect "Email"
send "$exp_3\r"

expect {
  timeout exit 1
  eof
}
