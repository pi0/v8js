# Based on https://github.com/phpv8/v8js/blob/master/README.Linux.md

FROM ubuntu
MAINTAINER Pooya Parsa <pooya@pi0.ir>
# use libicu of operating system
ENV GYP_DEFINES="use_system_icu=1"
# Build (with internal snapshots)
ENV GYPFLAGS "-Dv8_use_external_startup_data=0"
# Force gyp to use system-wide ld.gold
ENV GYPFLAGS "${GYPFLAGS} -Dlinux_use_bundled_gold=0"

# Install packages
RUN apt-get update \
 && apt-get install -y \
    libicu-dev build-essential git

# Install depot_tools first (needed for source checkout)
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH /depot_tools:"$PATH"
RUN apt-get -y install python
# Download v8
RUN fetch v8

# Compile v8
RUN cd v8 && make native library=shared snapshot=on -j8

# Install to /usr
RUN mkdir -p /usr/lib /usr/include \
 && cp v8/out/native/lib.target/lib*.so /usr/lib/ \
 && cp -R v8/include/* /usr/include

# Install libv8_libplatform.a (V8 >= 5.2.51)
COPY install.ar /
RUN cat /install.ar|ar -M

# Clone php-v8js
RUN git clone https://github.com/phpv8/v8js.git

# Compile
RUN apt-get install -y php php-dev
RUN cd v8js \
 && git checkout php7 \
 && phpize \
 && ./configure --with-v8js=/usr/local \
 && make \
 && make install

# Release script
COPY release.sh / 
