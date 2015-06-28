===========
Stan Cloud
===========

Stan Cloud is a service (à la manière de [tmpnb](https://github.com/jupyter/tmpnb))
which spawns temporary Jupyter notebooks with RStan, PyStan, and CmdStan installed.

Quickstart
==========

    docker build -t stan-dev/cloud .

    export IMAGE="stan-dev/cloud"
    export TOKEN=$( head -c 30 /dev/urandom | xxd -p )
    export CULL_TIMEOUT="$(( 3600 * 24))"
    docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=proxy jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999
    docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=tmpnb -v /var/run/docker.sock:/docker.sock \
           jupyter/tmpnb python orchestrate.py --image="$IMAGE" --cull_timeout="$CULL_TIMEOUT" --command="ipython notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port}"

Because ``docker`` is run with ``--net=host``, ports are automatically exposed.
