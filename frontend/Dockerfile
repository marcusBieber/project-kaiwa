FROM node:lts-alpine AS build

WORKDIR /kaiwa-frontend

COPY package.json ./

RUN apk add --no-cache --virtual .build-deps python3 make g++ \
    && npm install --omit=dev 

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /kaiwa-frontend/dist /usr/share/nginx/html

COPY --from=build /kaiwa-frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]