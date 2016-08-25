#!/usr/bin/expect -f 

trap {
 set rows [stty rows]
 set cols [stty columns]
 stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

if [info exists env(EXPECT_PROMPT)] {
    set prompt $env(EXPECT_PROMPT)
} else {
    #set prompt "(%|#|\\$) $"     ;# default prompt
    set prompt "\\$ $"     ;# default prompt
}
if [info exists env(EXPECT_PASSWORD)] {
	set password_prompt $env(EXPECT_PASSWORD)
} else {
	set password_prompt "assword:"
}
set confirm_prompt "onnecting (yes/no)?"

proc get_mac_keychain_pass {account} {
	global path
	log_user 0
	spawn security find-generic-password -l $account -g
	expect -re "password: \"(.*)\"" {
		set password $expect_out(1,string)
	}
	return $password
}

proc get_user_input {msg} {
	send_user "$msg"
	set input "" 
	stty -echo
	expect_user -re "(.*)\n" {
		set input $expect_out(1,string)
	}
	stty echo
	return $input
}

proc spawn_login {user_host password} {
	global prompt password_prompt confirm_prompt
	upvar spawn_id spawn_id
	upvar spawn_out spawn_out
	if [info exists ::env(SOCKS_PORT)] {
		puts "Setting up SOCKS proxy"
		set socks_port $::env(SOCKS_PORT)
		spawn ssh -D $socks_port $user_host
	} else {
		puts "No SOCKS proxy"
		spawn ssh $user_host
	}
	expect {
		-re $confirm_prompt { send "yes\r"; exp_continue; }
		-re $password_prompt { send "$password\r"; exp_continue; } 
		-re $prompt { } 
		timeout { send_user "unable to connect to $user_host\n" ; exit; }
	}
}

proc send_login {user_host password} {
	global prompt password_prompt confirm_prompt
	upvar spawn_id spawn_id
	upvar spawn_out spawn_out
	send "ssh $user_host\r"
	expect {
		-re $confirm_prompt { send "yes\r"; exp_continue; }
		-re $password_prompt { send "$password\r"; exp_continue; } 
		-re $prompt { } 
		timeout { send_user "unable to connect to $user_host\n" ; exit; }
	}
}

proc su {user password} {
	global prompt password_prompt
	upvar spawn_id spawn_id
	upvar spawn_out spawn_out
	send "su - $user\r"
	expect {
		-re $password_prompt { send "$password\r"; exp_continue; } 
		-re $prompt { } 
		timeout { send_user "unable to su to $user\n" ; exit; }
	}
}

proc mirror {password target_hosts args} {
	global prompt password_prompt
	upvar spawn_id spawn_id
	upvar spawn_out spawn_out
	set mir "mirror old-files $target_hosts \"[join $args "\" \""]\""
	send_user "$mir\n"
	send "$mir\r"
	expect {
		-re $password_prompt { send "$password\r" }
	}
	expect -re $prompt {
		return $expect_out(buffer);
	}
}
