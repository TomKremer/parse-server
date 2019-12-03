# Build stage
FROM node:10.13.0-alpine as build

RUN apk update; \
  apk add git; \
  apk add python; \
  apk add make; \
  apk add g++;
RUN npm install -g node-gyp
RUN npm install node-pre-gyp -g
WORKDIR /tmp
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Release stage
FROM node:10.13.0-alpine as release

RUN apk update; \
  apk add git; \
  apk add python;

VOLUME /parse-server/cloud /parse-server/config

WORKDIR /parse-server

COPY package*.json ./

RUN npm ci --production --ignore-scripts

COPY bin bin
COPY public_html public_html
COPY views views
COPY --from=build /tmp/lib lib
RUN mkdir -p logs && chown -R node: logs

ENV PORT=1337
USER node
EXPOSE $PORT

ENTRYPOINT ["node", "./bin/parse-server"]
