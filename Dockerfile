# Important: This file is provided for demonstration purposes and may NOT be suitable for production use.
# The maintainers of electrs are not deeply familiar with Docker, so you should DYOR.
# If you are not familiar with Docker either it's probably be safer to NOT use it.

ARG UID=1000
ARG GID=1000

FROM debian:bullseye-slim as base
ARG UID
ARG GID

RUN apt-get update -qqy
RUN apt-get install -qqy librocksdb-dev curl

RUN addgroup --gid $GID bitcoin
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID bitcoin

### Electrum Rust Server ###
FROM base as electrs-build
RUN apt-get install -qqy cargo clang cmake build-essential

# Install electrs
WORKDIR /build/electrs
COPY . .
ENV ROCKSDB_INCLUDE_DIR=/usr/include
ENV ROCKSDB_LIB_DIR=/usr/lib
RUN cargo install --locked --path .

FROM base as result
USER bitcoin
# Copy the binaries
COPY --from=electrs-build /root/.cargo/bin/electrs /usr/bin/electrs

WORKDIR /
