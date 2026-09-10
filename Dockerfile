# civicnet Core node (with ZMQ)
# Builds from the LOCAL source tree (./src).
FROM ubuntu:24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*

ENV PACKAGES="\
  build-essential pkg-config libtool git autoconf automake \
  libevent-dev libboost-chrono-dev libboost-filesystem-dev libboost-test-dev \
  libboost-thread-dev libssl-dev libzmq3-dev libdb++-dev libsqlite3-dev \
  libfmt-dev help2man bsdmainutils python3 patch \
"
RUN apt-get update && apt-get install --no-install-recommends -y $PACKAGES && rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /src
COPY src/ /src/
COPY patches/ /patches/

RUN for p in /patches/*.patch; do \
      [ -e "$p" ] || continue; \
      echo "Applying $p"; patch -p1 -d /src < "$p" || exit 1; \
    done

WORKDIR /src
RUN ./autogen.sh && \
    ./configure --disable-tests --without-gui --enable-zmq --disable-upnp --prefix=/build && \
    make -j$(nproc) -C src civicnet-node civicnet-cli civicnet-wallet && \
    mkdir -p /build/bin && \
    cp civicnet-node civicnet-cli civicnet-wallet /build/bin/

FROM ubuntu:24.04
WORKDIR /usr/local/
COPY --from=builder /build/ /usr/local/
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates libzmq5 && rm -rf /var/lib/apt/lists/*

VOLUME ["/data", "/root/.civicnet/civicnet.conf"]

EXPOSE 9333 9332 28332 28333 28334 28335

ENV NODE_BINS="civicnet-node civicnet-cli civicnet-wallet"
ENTRYPOINT ["/bin/sh", "-c", "set -- $NODE_BINS; exec /usr/local/bin/$1 \"$@\"", "sh"]
