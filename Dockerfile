FROM rustlang/rust:nightly as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y git bash make gcc linux-libc-dev patch musl musl-tools musl-dev

RUN rustup target add x86_64-unknown-linux-musl

COPY . /rumble-build

WORKDIR /rumble-build

RUN --mount=type=cache,target=/usr/local/cargo,from=rust,source=/usr/local/cargo \
    --mount=type=cache,target=target \
    cargo build --release --target x86_64-unknown-linux-musl && cp target/x86_64-unknown-linux-musl/release/rust-mumble /rust-mumble

FROM alpine:3.20

RUN apk add --no-cache ca-certificates

COPY --from=builder /rust-mumble /rust-mumble

EXPOSE 64738/udp
EXPOSE 64738/tcp

ENV MUMBLE_RESTRICT_TO_VERSION=CitizenFX
ENV MUMBLE_LISTENER=0.0.0.0:64738
ENV RUST_LOG=info

CMD /rust-mumble --listen "$MUMBLE_LISTENER" --restrict-to-version "$MUMBLE_RESTRICT_TO_VERSION"
