ARG RUST_VERSION=1.92
ARG ALPINE_VERSION=3.22
ARG APP_NAME=app

FROM rust:${RUST_VERSION}-alpine${ALPINE_VERSION} AS build
WORKDIR /app

# Install host build dependencies.
RUN apk add --no-cache clang lld musl-dev git

ARG APP_NAME

# Build the application
RUN --mount=type=bind,source=src,target=src \
    --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
    --mount=type=bind,source=Cargo.lock,target=Cargo.lock \
    --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/ \
    cargo build --locked --release && \
    cp ./target/release/${APP_NAME} /bin/${APP_NAME}

# scratch или distroless будут еще меньше
FROM alpine:$ALPINE_VERSION AS final
ARG APP_NAME
# Create a non-privileged user that the app will run under.
ARG UID=10001

RUN adduser \
--disabled-password \
--gecos "" \
--home "/nonexistent" \
--shell "/sbin/nologin" \
--no-create-home \
--uid "${UID}" \
appuser

# Copy the executable from the "build" stage.
COPY --from=build /bin/${APP_NAME} /bin/app

USER appuser
EXPOSE 3000

# What the container should run when it is started.
ENTRYPOINT ["/usr/local/bin/app"]
