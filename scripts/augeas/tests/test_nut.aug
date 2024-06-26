(* Tests for the Nut module *)

module Test_nut =

let nut_conf = "
MODE=standalone
"

test NutNutConf.nut_lns get nut_conf = 
	{ }
	{ "MODE" = "standalone" }

(* desc is a single token made of two words below *)
let ups_conf1 = "
[testups]
	driver = dummy-ups
	port = auto
	desc = \"Dummy UPS Driver\"
"

test NutUpsConf.ups_lns get ups_conf1 =
	{ }
	{ "testups"
		{ "driver" = "dummy-ups"   }
		{ "port"   = "auto" }
		{ "desc"   = "Dummy UPS Driver"    } }

(* desc is a single token made of two words prefixed by one quote
 * as part of its content below (escaped by backslashes) *)
let ups_conf2 = "
[testups]
	driver = dummy-ups
	port = auto
	desc = \"\\\"Dummy UPS\" # comment line
"

test NutUpsConf.ups_lns get ups_conf2 =
	{ }
	{ "testups"
		{ "driver" = "dummy-ups"   }
		{ "port"   = "auto" }
		{ "desc"   = "\\\"Dummy UPS"
			{ "#comment" = "comment line" }
		}
	}

(* desc is a single token made of two words surrounded by quotes
 * as part of its content below (escaped by backslashes) *)
(* FIXME: Lens fails to parse the second escaped slash, probably
 *        because of "to_comment_re" or "entry_generic_nocomment"
 *        test below is truncated so far:
 * ./tests/test_nut.aug:53.0-58.41:exception thrown in test
 * ./tests/test_nut.aug:53.5-.37:exception: Get did not match entire input
 *     Lens: /usr/share/augeas/lenses/dist/inifile.aug:497.25-.43:
 *     Error encountered at 5:0 (44 characters into string)
 *     <er = dummy-ups\n\tport = auto\n|=|\tdesc = "\"Dummy UPS\""\n>
 *
 *     Tree generated so far:
 *     /testups
 * /testups/driver = "dummy-ups"
 * /testups/port = "auto"
 *
 * NOTE That for NUT parsing, such trailing slash is likely a problem
 * that is not caught by lens parser either: it should mean escaping
 * the next character (quote) and so an unfinished line. This test case
 * should have failed but currently does not.
 *)
let ups_conf3 = "
[testups]
	driver = dummy-ups
	port = auto
	desc = \"\\\"Dummy UPS\\\"
"

test NutUpsConf.ups_lns get ups_conf3 =
	{ }
	{ "testups"
		{ "driver" = "dummy-ups"   }
		{ "port"   = "auto" }
		{ "desc"   = "\\\"Dummy UPS\\"    } }



let upsd_conf = "
MAXAGE 30
TRACKINGDELAY 600
ALLOW_NO_DEVICE 1
LISTEN 0.0.0.0 3493
MAXCONN 1024
"

test NutUpsdConf.upsd_lns get upsd_conf = 
	{ }
	{ "MAXAGE"      = "30" }
	{ "TRACKINGDELAY" = "600" }
	{ "ALLOW_NO_DEVICE" = "1" }
	{ "LISTEN"
		{ "interface" = "0.0.0.0" }
		{ "port"     = "3493"     } }
	{ "MAXCONN"      = "1024" }

let upsd_users = "
	[admin]
		password = upsman
		actions = SET FSD
		instcmds = ALL

	[pfy]
		password = duh
		instcmds = test.panel.start
		instcmds = test.panel.stop

	[upswired]
		password = blah
		upsmon primary

	[observer]
		password = abcd
		upsmon secondary
"

test NutUpsdUsers.upsd_users_lns get upsd_users = 
	{ }
	{ "admin"
		{ "password" = "upsman" }
		{ "actions"
			{ "SET" }
			{ "FSD" } }
		{ "instcmds" = "ALL" }
		{ }  }
	{ "pfy"
		{ "password" = "duh" }
		{ "instcmds" = "test.panel.start" }
		{ "instcmds" = "test.panel.stop" }
		{ }  }
	{ "upswired"
		{ "password" = "blah" }
		{ "upsmon" = "primary" }
		{ }  }
	{ "observer"
		{ "password" = "abcd" }
		{ "upsmon" = "secondary" } }

let upsmon_conf = "
MONITOR testups@localhost 1 upswired blah primary

MINSUPPLIES 1
SHUTDOWNCMD /sbin/shutdown -h +0
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 30
DEADTIME 15
POWERDOWNFLAG /etc/killpower
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5
"

test NutUpsmonConf.upsmon_lns get upsmon_conf =
	{ }
	{ "MONITOR"
		{ "system"
		{ "upsname"  = "testups"    }
		{ "hostname" = "localhost" } }
		{ "powervalue" = "1"                }
		{ "username"   = "upswired"          }
		{ "password"   = "blah"           }
		{ "type"       = "primary"           } }
	{ }
	{ "MINSUPPLIES"   = "1"  }
	{ "SHUTDOWNCMD"   = "/sbin/shutdown -h +0" }
	{ "POLLFREQ"      = "5"  }
	{ "POLLFREQALERT" = "5"  }
	{ "HOSTSYNC"      = "30" }
	{ "DEADTIME"      = "15" }
	{ "POWERDOWNFLAG" = "/etc/killpower" }
	{ "RBWARNTIME"    = "43200" }
	{ "NOCOMMWARNTIME" = "300" }
	{ "FINALDELAY"    = "5" }

let upsset_conf = "
 I_HAVE_SECURED_MY_CGI_DIRECTORY
"

test NutUpssetConf.upsset_lns get upsset_conf = 
	{ }
	{ "auth"	= "I_HAVE_SECURED_MY_CGI_DIRECTORY" }


let upssched_conf = "
CMDSCRIPT /upssched-cmd
PIPEFN /var/state/ups/upssched/upssched.pipe
LOCKFN /var/state/ups/upssched/upssched.lock
AT COMMBAD * START-TIMER upsgone 10
AT COMMOK myups@localhost CANCEL-TIMER upsgone
AT ONLINE * EXECUTE ups-back-on-line
"

test NutUpsschedConf.upssched_lns get upssched_conf =
	{ }
	{ "CMDSCRIPT"	= "/upssched-cmd" }
	{ "PIPEFN"	= "/var/state/ups/upssched/upssched.pipe" }
	{ "LOCKFN"	= "/var/state/ups/upssched/upssched.lock" }
	{ "AT" 
		{ "notifytype" = "COMMBAD" }
		{ "upsname" = "*" }
		{ "START-TIMER"
			{ "timername" = "upsgone" }
			{ "interval" = "10" }
		}
	}
	{ "AT" 
		{ "notifytype" = "COMMOK" }
		{ "upsname" = "myups@localhost" }
		{ "CANCEL-TIMER"
			{ "timername" = "upsgone" }
		}
	}
	{ "AT" 
		{ "notifytype" = "ONLINE" }
		{ "upsname" = "*" }
		{ "EXECUTE"
			{ "command" = "ups-back-on-line" }
		}
	}


let hosts_conf = "
MONITOR myups@localhost \"Local UPS\"
MONITOR su2200@10.64.1.1 \"Finance department\"
MONITOR matrix@shs-server.example.edu \"Sierra High School data room #1\"
"

test NutHostsConf.hosts_lns get hosts_conf =
	{ }
	{ "MONITOR" 
		{ "system" = "myups@localhost" }
		{ "description" = "Local UPS" }
	}
	{ "MONITOR" 
		{ "system" = "su2200@10.64.1.1" }
		{ "description" = "Finance department" }
	}
	{ "MONITOR" 
		{ "system" = "matrix@shs-server.example.edu" }
		{ "description" = "Sierra High School data room #1" }
	}
