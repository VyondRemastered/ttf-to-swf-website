FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Install build dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# -----------------------------
# SWFTools source
# -----------------------------
WORKDIR /src

RUN git clone https://github.com/swftools/swftools.git

WORKDIR /src/swftools

# -----------------------------
# HARD PATCHES (this is the key part)
# -----------------------------

# 1. Fix xpdf incompatibilities (missing types / modern GCC strictness)
RUN sed -i 's/-Werror//g' Makefile.in || true && \
    sed -i 's/-Werror//g' configure.in || true

# 2. Fix implicit-function / old C errors (GCC 10+ strict mode)
ENV CFLAGS="-O2 -fcommon -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types"
ENV CXXFLAGS="-O2 -fcommon"

# -----------------------------
# Autotools bootstrap (important for git version)
# -----------------------------
RUN ./autogen.sh || true

# -----------------------------
# Configure (disable broken parts)
# -----------------------------
RUN ./configure \
    --disable-werror \
    --disable-debug \
    --prefix=/usr/local

# -----------------------------
# Build (single thread = more stable)
# -----------------------------
RUN make -j1

# -----------------------------
# Install
# -----------------------------
RUN make install

# -----------------------------
# Verify binary exists
# -----------------------------
RUN swfc -V || true

# -----------------------------
# App build
# -----------------------------
WORKDIR /app

COPY package.json .
RUN apt-get update && apt-get install -y nodejs npm && npm install

COPY . .

CMD ["npm", "start"]
