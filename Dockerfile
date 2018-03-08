FROM mhart/alpine-node:8.7.0

RUN apk add --no-cache tini bash
WORKDIR /
COPY ./package.json /package.json
RUN npm install

# Tini is now available at /sbin/tini
ENTRYPOINT ["/sbin/tini", "--", "bash", "./test-inbox.sh"]
RUN mkdir /data
VOLUME /data

# Set to 1, to start a server instead of just a cli
ENV SERVER_AUTH=

COPY . /
