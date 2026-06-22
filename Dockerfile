FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libgif-dev \
    wget

# download SWFTools source
RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/matthiaskramm/swftools.git \
    && cd swftools \
    && ./configure \
    && make \
    && make install

# Node setup
RUN apt-get install -y nodejs npm

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "start"]
