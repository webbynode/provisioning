{
	"deployer": {
		"home": "/var/apps",
		"password": "$1$gdQZBxNP$jgWCYUfBF9fMXVO2jnpoh1"
	},
	"database": {
	  "server": "mysql",
	  "password": "tempra13"
	},
	"webserver": {
	  "id": "nginx",
	  "name": "Nginx",
	  "initd": "nginx",
	  "root": "/etc/nginx"
	},
	"ssh": {
	  "keys": [
	    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoWL1H1e2kxmtS2+87Ax6SSS1XBcpZcmE3E7nmAnmvGa2ImUxMFSt1/EzL1xQDgv/iavw0vtElrO+K/IynhUWfatzsNfD1cFPbTa2vmh0c1mYwQKgA9AOwSCmyZn5bctaUUqQITBN2LQXEPFWaJi3spPaoli8HjC0gTZKLMJG0tAMPTtdSvI/ngTG3I1tml6fHCGhDEJnPQQuCngprksZKVMKV9Wtocdc/wpZt2JjuNbYiu0SCLP0/64ka64hFf2sXzzhQAQTlTUMMc7ijEtkpAIt8cBGgQNbYgxkbE5YczWGebyKzJmkykYjGp68AofHelCB2jeolJ+5txRFuXaUFQ== fcoury@macbook.local"
	  ]
	},
	"mysql": {
	  "server_root_password": "tempra13"
	},
  "run_list": [ "recipe[passenger::nginx]", "recipe[webbynode::default]" ]
}