FROM alpine as puller

# Pull the latest version of the code from: https://github.com/itteco/iframely
RUN apk add --no-cache git

WORKDIR /opt/iframely
RUN git clone https://github.com/itteco/iframely.git /opt/iframely --depth 1 --branch main

# Build the final image
FROM node:17.8-alpine3.15 as builder

EXPOSE 8061

WORKDIR /iframely

# Create new non-root user
RUN addgroup -S iframelygroup && adduser -S iframely -G iframelygroup
RUN apk add g++ make python3

# This will change the config to `config.<VALUE>.js` and the express server to change its behaviour.
# You should overwrite this on the CLI with `-e NODE_ENV=production`.
ENV NODE_ENV=local

## Utilize docker layer cache
COPY --from=puller /opt/iframely /iframely

RUN yarn install --pure-lockfile --production

COPY --chown=iframely config.local.js /iframely/config.local.js

USER iframely

ENTRYPOINT [ "node", "cluster.js" ]