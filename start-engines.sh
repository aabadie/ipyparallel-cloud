#!/bin/bash

exec su $BASICUSER -c "env PATH=$PATH ipengine --ip=172.28.1.1 --port=8889$*"
