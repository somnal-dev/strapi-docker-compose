# Creating multi-stage build for production
FROM node:22-alpine AS build
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Yarn Berry 설정
RUN corepack enable
RUN yarn set version berry
RUN yarn install --immutable

# 소스 코드 복사
COPY . .
RUN yarn build

# Creating final production image
FROM node:22-alpine
RUN apk add --no-cache vips-dev
ENV NODE_ENV=production
WORKDIR /opt/app

# 빌드 결과물 복사
COPY --from=build /opt/app ./

RUN corepack enable
RUN chown -R node:node /opt/app
USER node
EXPOSE 1337
CMD ["yarn", "start"]