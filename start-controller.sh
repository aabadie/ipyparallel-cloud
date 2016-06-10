#!/bin/bash

exec su $BASICUSER -c "env PATH=$PATH ipcontroller --host=172.28.1.1 --port 8889$*"&
exec su $BASICUSER -c "env PATH=$PATH jupyter notebook --ip='*' --no-browser $*"
