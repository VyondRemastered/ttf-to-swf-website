FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Install SWFTools (prebuilt)
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    swftools \
    fontconfig \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Verify tool exists
# -----------------------------
RUN font2swf -h || true

# -----------------------------
# App setup (optional Node layer)
# -----------------------------
WORKDIR /app

# install node (if you actually need it)
RUN apt-get update && apt-get install -y nodejs npm \
    && rm -rf /var/lib/apt/lists/*

COPY package.json ./
RUN npm install

COPY . .

# -----------------------------
# Default command
# -----------------------------
CMD ["npm", "start"]
