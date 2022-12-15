FROM debian:bullseye as builder

ARG NODE_VERSION=16.18.1
ARG YARN_VERSION=1.22.19

RUN apt-get update; apt install -y curl
RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH /root/.volta/bin:$PATH
RUN volta install node@${NODE_VERSION} yarn@${YARN_VERSION}

#######################################################################

RUN mkdir /app
WORKDIR /app

ENV NODE_ENV build

COPY . .

RUN npm i
RUN npm run build \
    && npm prune --production

FROM debian:bullseye

ENV NODE_ENV production

LABEL fly_launch_runtime="nodejs"

COPY --from=builder /root/.volta /root/.volta
COPY --from=builder /app /app

WORKDIR /app
ENV NODE_ENV production
ENV PATH /root/.volta/bin:$PATH

CMD [ "node", "dist/shared/server" ]