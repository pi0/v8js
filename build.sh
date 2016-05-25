#!/bin/bash
docker build -t pooya/v8js -f Dockerfile .
mkdir -p release
docker run -it --rm -v `pwd`/release:/release pooya/v8js /release.sh
tar -cJf v8js.txz release
