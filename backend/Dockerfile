FROM node:lts-alpine

WORKDIR /backend

COPY . .

RUN apk add --no-cache --virtual .build-deps python3 make g++ \
    && npm install --omit=dev \
    && apk del .build-deps

EXPOSE 3001

CMD ["node", "server.js"]