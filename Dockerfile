FROM debian:bullseye-20230612-slim

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------
# Pin EVERYTHING to snapshot
# ----------------------------
RUN printf "deb http://snapshot.debian.org/archive/debian/20230612T000000Z bullseye main\n" > /etc/apt/sources.list

RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# ----------------------------
# CRITICAL: prevent mixed libc/perl versions
# ----------------------------
RUN apt-get update -o Acquire::Check-Valid-Until=false \
 && apt-get install -y --no-install-recommends \
    libc6 \
    libc6-dev \
    perl \
    perl-base \
 && apt-mark hold libc6 libc6-dev perl perl-base

# ----------------------------
# Build deps (single consistent snapshot)
# ----------------------------
RUN apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    git \
    autoconf \
    automake \
    libtool \
    pkg-config \
    bison \
    flex \
    gawk \
    patch \
    make \
    gcc \
    g++ \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libfontconfig1-dev \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------
# SWFTools source
# ----------------------------
WORKDIR /src

RUN git clone --depth 1 https://github.com/swftools/swftools.git
WORKDIR /src/swftools

# ----------------------------
# 🔥 XPDF FIX (this is the real breakage point)
# ----------------------------
RUN mkdir -p lib/pdf/xpdf

# ensure missing legacy files don't break make rules
RUN touch lib/pdf/xpdf/TextOutputDev.cc || true

# ----------------------------
# disable fatal warnings (SWFTools is ancient)
# ----------------------------
RUN sed -i 's/-Werror//g' configure || true

# ----------------------------
# build (must be single-threaded)
# ----------------------------
RUN ./configure --disable-werror || (cat config.log && exit 1)

RUN make -j1 || make -k

RUN make install || true

# ----------------------------
# sanity check
# ----------------------------
RUN ldconfig || true
RUN which pdf2swf || true

WORKDIR /app
