FROM python:3.13-alpine3.21 as base
LABEL maintainer="Ben Hardill hardillb@gmail.com"
RUN apk add --no-cache --update  \
  dbus-libs \
  'nodejs<23'

# Install dependencies
FROM base as compile-image

WORKDIR /usr/src/app

RUN apk add --no-cache --update \
    cmake \
    g++ \
    glib-dev \
    dbus \
    dbus-dev \
    glib-dev \
    ninja \
    'npm<11' && \
  pip install --upgrade --no-cache-dir pip

RUN pip install --user --no-cache-dir mdns-publisher

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Build application
FROM base as build-image

WORKDIR /usr/src/app

# app
COPY cname.py index.js ./
# npm packages
COPY --from=compile-image /usr/src/app/node_modules node_modules
# pip packages
COPY --from=compile-image /root/.local /root/.local
ENV PATH=/root/.local/bin:/usr/src/app:$PATH

WORKDIR /tmp

CMD ["node", "/usr/src/app/index.js"]
