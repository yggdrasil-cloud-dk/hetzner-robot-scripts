#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ -f .env ]; then
	# shellcheck disable=SC1091
	. .env
fi

usage() {
	cat <<'EOF'
Usage: ./set-FW-rule.sh SERVER RULE_NAME IP_VERSION PROTOCOL SOURCE_IP DESTINATION_IP SOURCE_PORT DESTINATION_PORT TCP_FLAGS ACTION

Set one input rule on a server's Hetzner Robot firewall. Use "-" for an
unused rule value. IP_VERSION must be ipv4 or ipv6, and ACTION must be accept
or discard.

Example:
  ./set-FW-rule.sh 123456 ssh ipv4 tcp 203.0.113.10/32 - - 22 syn accept
EOF
}

if [ "$#" -ne 10 ]; then
	echo "Incorrect argument count." >&2
	usage >&2
	exit 1
fi

: "${USERNAME:?Set USERNAME in .env or the environment}"
: "${PASSWORD:?Set PASSWORD in .env or the environment}"

server_number=$1
rule_name=$2
ip_version=$3
protocol=$4
source_ip=$5
destination_ip=$6
source_port=$7
destination_port=$8
tcp_flags=$9
action=${10}

case "$server_number" in
	''|*[!0-9]*) echo "SERVER must be a numeric server number." >&2; exit 1 ;;
esac

case "$ip_version" in
	ipv4|ipv6) ;;
	*) echo "IP_VERSION must be ipv4 or ipv6." >&2; exit 1 ;;
esac

case "$action" in
	accept|discard) ;;
	*) echo "ACTION must be accept or discard." >&2; exit 1 ;;
esac

# A dash makes optional values convenient to express without relying on empty
# positional arguments. The Robot API represents an unused field as empty.
empty_dash() {
	if [ "$1" = "-" ]; then
		printf '%s' ''
	else
		printf '%s' "$1"
	fi
}

source_ip=$(empty_dash "$source_ip")
destination_ip=$(empty_dash "$destination_ip")
source_port=$(empty_dash "$source_port")
destination_port=$(empty_dash "$destination_port")
tcp_flags=$(empty_dash "$tcp_flags")

echo "$server_number: Setting Hetzner firewall input rule '$rule_name'.."

curl --fail --silent --show-error \
	-u "$USERNAME:$PASSWORD" \
	-X POST "https://robot-ws.your-server.de/firewall/$server_number" \
	--data-urlencode "rules[input][0][name]=$rule_name" \
	--data-urlencode "rules[input][0][ip_version]=$ip_version" \
	--data-urlencode "rules[input][0][protocol]=$protocol" \
	--data-urlencode "rules[input][0][src_ip]=$source_ip" \
	--data-urlencode "rules[input][0][dst_ip]=$destination_ip" \
	--data-urlencode "rules[input][0][src_port]=$source_port" \
	--data-urlencode "rules[input][0][dst_port]=$destination_port" \
	--data-urlencode "rules[input][0][tcp_flags]=$tcp_flags" \
	--data-urlencode "rules[input][0][action]=$action" |
	jq .
