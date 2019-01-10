FROM node:8.15-stretch-slim as foobar

# RUN apt-get update && apt-get install -y npm nodejs

RUN useradd jeopardy

ENV HOME=/code
WORKDIR /code/jeopardy/frontend
RUN chown node:node /code

EXPOSE 3000

FROM nginx:1.15-alpine as foobar2
