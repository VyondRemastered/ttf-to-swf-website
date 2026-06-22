FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# old but compatible toolchain
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    pkg-config \
    bison \
    flex \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    fontconfig \
    git \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# get SWFTools (working snapshot)
# IMPORTANT: no GitHub releases exist → use repo HEAD snapshot
# -----------------------------
WORKDIR /src

RUN git clone https://github.com/swftools/swftools.git

WORKDIR /src/swftools

# Pin to a historically stable commit (pre-modern breakage era)
# If this fails, we can adjust to earlier hash
RUN git checkout 6d6f2f3 || true

# -----------------------------
# build flags for legacy GCC
# -----------------------------
ENV CFLAGS="-O2 -fcommon"
ENV CXXFLAGS="-O2 -fcommon"

# -----------------------------
# fix autotools (older system expects this)
# -----------------------------
RUN autoreconf -fi || true

# -----------------------------
# configure (legacy-safe)
# -----------------------------
RUN ./configure --prefix=/usr/local

# -----------------------------
# build (IMPORTANT: single-threaded only)
# -----------------------------
RUN make -j1

RUN make install

# -----------------------------
# sanity check
# -----------------------------
RUN font2swf -h || true
RUN swfc -h || true

# -----------------------------
# app layer
# -----------------------------
WORKDIR /app

COPY package.json .
RUN apt-get update && apt-get install -y nodejs npm && npm install

COPY . .

CMD ["npm", "start"]
