FROM ruby:3.3-bookworm@sha256:1a41ebabaa0e2d4f3383cdd32170423fb9f7d3c641f9de21745bc33a0f9ab957

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential make \
 && rm -rf /var/lib/apt/lists/*

COPY .vendor/.zed/oresoftware/flags-2-env ./.vendor/.zed/oresoftware/flags-2-env
RUN make -C .vendor/.zed/oresoftware/flags-2-env clean && make -C .vendor/.zed/oresoftware/flags-2-env shared

COPY .cli-flags.toml ./
COPY src ./src

# The Ruby client resolves its native library from this variable at require
# time, so it has to be set before the require, not just before the call.
ENV FLAGS2ENV_NATIVE_LIB=/app/.vendor/.zed/oresoftware/flags-2-env/build/libflags2env.so

RUN useradd --create-home --shell /bin/sh --uid 10001 fixture
USER fixture

CMD ["ruby", "src/demo.rb"]
