#!/bin/bash

print_help () {
    cat << EOF
    Usage:
    -h this screen
    -f need floating, if not set  - don't need floating
EOF
  exit
}

echo_inform () {
	echo "=========================> $@ <================================="
}
