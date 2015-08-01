===========
Stan Cloud
===========

Stan Cloud is a service (à la manière de [tmpnb](https://github.com/jupyter/tmpnb))
which spawns temporary Jupyter notebooks with RStan, PyStan, and CmdStan installed.

Quickstart
==========

    docker build -t stan-cloud .

    IMAGE="stan-cloud"
    TOKEN=$( head -c 30 /dev/urandom | xxd -p )
    CULL_TIMEOUT=3600
    MEM_LIMIT="1024m"  # per-container memory limit
    docker run --net=host -d -e "CONFIGPROXY_AUTH_TOKEN=$TOKEN" --name=proxy jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999
    docker run --net=host -d -e "CONFIGPROXY_AUTH_TOKEN=$TOKEN" --name=tmpnb -v /var/run/docker.sock:/docker.sock \
           jupyter/tmpnb python orchestrate.py --image="$IMAGE" --cull_timeout="$CULL_TIMEOUT" --mem_limit="$MEM_LIMIT" --command="ipython notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port}"

Because ``docker`` is run with ``--net=host``, ports are automatically exposed.

``tmpnb`` exposes port 8000 by default. If you want to redirect web traffic, the following iptables
rule will do the trick:

    /sbin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8000

systemd service files
=====================

- ``configproxy.service``

```
[Unit]
Description=ConfigProxy
After=docker.service
Requires=docker.service
[Service]
Restart=always
Environment="TOKEN=SECRETTOKEN"
ExecStartPre=-/usr/bin/docker kill configproxy
ExecStartPre=-/usr/bin/docker rm configproxy
ExecStartPre=/usr/bin/docker pull jupyter/configurable-http-proxy
ExecStart=/usr/bin/docker run --net=host --rm --name configproxy -e CONFIGPROXY_AUTH_TOKEN=$TOKEN jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999
ExecStop=/usr/bin/docker rm -f configproxy
[Install]
WantedBy=tmpnb.target
```

- ``tmpnb.service``

```
[Unit]
Description=tmpnb
After=configproxy.service
Requires=configproxy.service
[Service]
Restart=always
Environment="TOKEN=SECRETTOKEN"
Environment="IMAGE=stan-cloud"
Environment="CULL_TIMEOUT=3600"
Environment="MEM_LIMIT=1024m"
ExecStartPre=-/usr/bin/docker kill tmpnb
ExecStartPre=-/usr/bin/docker rm tmpnb
ExecStartPre=/usr//usr/bin/docker pull jupyter/tmpnb
ExecStart=/usr/bin/docker run --net=host -e "CONFIGPROXY_AUTH_TOKEN=$TOKEN" --name=tmpnb -v /var/run/docker.sock:/docker.sock \
    jupyter/tmpnb python orchestrate.py --image="$IMAGE" --cull_timeout="$CULL_TIMEOUT" --mem_limit="$MEM_LIMIT" --command="ipython notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port}"
ExecStop=/usr/bin/docker rm -f tmpnb
[Install]
WantedBy=tmpnb.target
```

- ``port-80-redirect-iptables.service``

```
[Unit]
Description=Redirect 80 to 8000
After=tmpnb.service
[Service]
Type=oneshot
ExecStart=/usr/sbin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8000
```
