FROM kylemanna/openvpn:latest

RUN ovpn_genconfig -d -N -u udp://127.0.0.1

RUN echo | ovpn_initpki nopass

RUN easyrsa build-client-full mynet-vpn-client nopass

RUN ( \
    ovpn_getclient mynet-vpn-client \
    && echo route-nopull \
    && echo route 10.10.10.0 255.255.255.0 \
    ) > /hadoop-cluster-1.ovpn

CMD ["/bin/sh", "-c", "cat /hadoop-cluster-1.ovpn > /hadoop-cluster.ovpn; ovpn_run"]