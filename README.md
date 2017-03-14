# FIXME

https://community.openvpn.net/openvpn/wiki/SWEET32

	docker run --rm -it kylemanna/openvpn sh
	# where?
	--cipher AES-256-CBC

Answer  
https://github.com/kylemanna/docker-openvpn/issues/163#issuecomment-277008738


# Server
([Run client](#client) see bottom)

**Note:** the cert passphrase you will find in the admin.kdbx

## Setup (only once)

```shell
$ OVPN_DATA="ovpn-data"
$ docker volume create --name $OVPN_DATA
$ docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn \
    ovpn_genconfig -u udp://heisenberg.aptly.de
$ docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
```

### Create & run OpenVPN server

```shell
$ docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN \
    --name openvpn kylemanna/openvpn
```

## Start/stop OpenVPN server

```shell
$ docker start openvpn
$ docker stop openvpn
```

## Create clients (example!)

```shell
$ for CLIENTNAME in lschr mthielcke dsteiner; do \
  docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENTNAME nopass; \
  docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn; \
done
```

<a id="client"></a>

# Run client (Linux, your local machine)

```shell
$ sudo openvpn --config dsteiner.ovpn
$ sudo openvpn --config dsteiner.ovpn --daemon # background
```
