FROM ruby:3.3-bookworm

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

CMD ["ruby", "src/demo.rb"]
