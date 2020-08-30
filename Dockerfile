FROM ruby:2.7.1-alpine

ENV BUNDLER_VERSION=2.1.4
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

RUN apk add --update --no-cache \
      binutils-gold \
      build-base \
      file \
      g++ \
      gcc \
      git \
      less \
      libstdc++ \
      libffi-dev \
      libc-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      postgresql-dev \
      python3 \
      tzdata \
      yarn

RUN gem install bundler -v 2.1.4

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# Setup gemfiles
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install

# Setup js assets
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --no-cache --production

COPY . ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
    && RAILS_ENV=production rake assets:precompile \
    && apk del .gyp

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
