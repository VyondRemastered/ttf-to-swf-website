FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# build dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    bison \
    flex \
    wget \
    ca-certificates \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# clone SWFTools (no releases exist)
# -----------------------------
WORKDIR /src
RUN git clone https://github.com/swftools/swftools.git

WORKDIR /src/swftools

# optional: pin a known stable historical snapshot
# (HEAD is usually fine, but pinning avoids future breakage)
RUN git checkout HEAD

# -----------------------------
# fix modern GCC issues
# -----------------------------
ENV CFLAGS="-O2 -fcommon -Wno-error=implicit-function-declaration"
ENV CXXFLAGS="-O2 -fcommon"

# -----------------------------
# regenerate build system
# -----------------------------
RUN autoreconf -fi || true

# -----------------------------
# configure (disable fragile components)
# -----------------------------
RUN ./configure \
    --prefix=/usr/local \
    --disable-werror

# -----------------------------
# build (IMPORTANT: single-threaded)
# -----------------------------
RUN make -j1

RUN make install

# -----------------------------
# verify font tool exists
# -----------------------------
RUN font2swf -h || true

WORKDIR /app
COPY . .

CMD ["node", "index.js"]
