#!/bin/sh
# 
# ------------------------------------------------------------------------------
# ISC License http://opensource.org/licenses/isc-license.txt
# ------------------------------------------------------------------------------
# Copyright (c) 2017, Dittmar Steiner <dittmar.steiner@googlemail.com>
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

VERSION=1.0

set -e

[ -z "$1" ] && {
    echo "Version $VERSION"
    echo "Usage:";
    echo "  ./$(basename $0) <your>.ovpn"
    exit 1;
}

NAME=$(basename $1)
NAME="openvpn-${NAME%.*}"

FILE=$(realpath $1)

# container exists
[ $(docker ps -aqf "name=$NAME" | grep -cE '.+') != 0 ] || {
    docker create --name $NAME -itv $FILE:/config.ovpn \
    --net=host --cap-add=NET_ADMIN --device /dev/net/tun \
    kylemanna/openvpn openvpn --config /config.ovpn;
    EXIT_CODE=$?;
    [ $EXIT_CODE = 0 ] || { exit $EXIT_CODE; }
}

# toggle container
[ $(docker ps -qf "name=$NAME" | grep -cE '.+') != 0 ] && {
    echo "Your IP is: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo -n "Stopping "
    docker stop $NAME;
    EXIT_CODE=$?
    docker ps -af "name=$NAME";
    for i in $(seq 3); do echo -n '.'; sleep 1; done
    echo
    echo "Your IP is: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    exit $EXIT_CODE;
} || {
    echo "Your IP is: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    echo -n "Starting "
    docker start $NAME;
    EXIT_CODE=$?
    docker ps -af "name=$NAME";
    for i in $(seq 4); do echo -n '.'; sleep 1; done
    echo
    echo "Your IP is: $(dig +short myip.opendns.com @resolver1.opendns.com)"
    exit $EXIT_CODE;
}
