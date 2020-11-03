FROM node:10-slim

ENV SASS_BINARY_SITE=https://npm.taobao.org/mirrors/node-sass/
ENV PHANTOMJS_CDNURL=https://npm.taobao.org/mirrors/phantomjs/

WORKDIR /drone/

COPY ./package.json /drone/
COPY ./yarn.lock /drone/

RUN yarn