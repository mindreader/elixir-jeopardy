FROM node:8.15-stretch-slim as dev

# RUN apt-get update && apt-get install -y npm nodejs

RUN useradd jeopardy

ENV HOME=/code
WORKDIR /code/jeopardy/frontend
RUN chown node:node /code

EXPOSE 3000

FROM dev as build

COPY package-lock.json  package.json ./
COPY public/ ./public/
COPY src/ ./src/

RUN npm i
RUN npm run build

FROM nginx:1.15-alpine as prod

COPY --from=build /code/jeopardy/frontend/build/ /usr/share/nginx/html/jeopardy
RUN rm -f /etc/nginx/conf.d/default.conf

COPY resources/jeopardy_nginx.conf /etc/nginx/conf.d/jeopardy.conf

FROM prod
