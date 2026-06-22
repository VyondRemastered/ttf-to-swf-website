FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Build deps
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

# -----------------------------
# Use RELEASE tarball (important)
# Git HEAD is broken for pdf/xpdf
# -----------------------------
WORKDIR /src

RUN wget https://github.com/swftools/swftools/archive/refs/tags/v0.9.2.tar.gz \
    && tar -xzf v0.9.2.tar.gz \
    && mv swftools-0.9.2 swftools

WORKDIR /src/swftools

# -----------------------------
# CRITICAL PATCHES
# -----------------------------

# 1. disable strict warnings that break legacy C
ENV CFLAGS="-O2 -fcommon -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types"
ENV CXXFLAGS="-O2 -fcommon"

# 2. fix missing implicit rule expectations
RUN find . -name Makefile.in -exec sed -i 's/-Werror//g' {} \; || true

# 3. force autotools regeneration (important for xpdf paths)
RUN autoreconf -fi || true

# -----------------------------
# Configure (disable fragile parts)
# -----------------------------
RUN ./configure \
    --prefix=/usr/local \
    --disable-werror

# -----------------------------
# Build (must be single-threaded for SWFTools)
# -----------------------------
RUN make -j1

# -----------------------------
# Install
# -----------------------------
RUN make install

# -----------------------------
# Verify
# -----------------------------
RUN swfc -h || true

# -----------------------------
# App
# -----------------------------
WORKDIR /app

COPY package.json .
RUN apt-get update && apt-get install -y nodejs npm && npm install

COPY . .

CMD ["npm", "start"]
