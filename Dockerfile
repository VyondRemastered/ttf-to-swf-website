FROM debian:bullseye

RUN apt-get update && apt-get install -y ca-certificates wget gnupg

# allow expired snapshot repo metadata
RUN echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/99no-check-valid-until

# use snapshot repo
RUN echo "deb http://snapshot.debian.org/archive/debian/20210101T000000Z bullseye main" > /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    swftools \
    nodejs \
    npm \
    ca-certificates

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

CMD ["npm", "start"]
