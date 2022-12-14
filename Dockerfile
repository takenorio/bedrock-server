FROM debian:bullseye-slim AS builder

ARG USER_AGENT='Mozilla/5.0 (Macintosh; Ikageso)'
ARG DOWNLOAD_URL='https://www.minecraft.net/en-us/download/server/bedrock'

WORKDIR /bedrock

RUN apt-get -qq update \
    && apt-get -y install curl unzip \
    && SERVER_ARCHIVE=$(curl -sH "User-Agent: $USER_AGENT" "$DOWNLOAD_URL" \
        | grep -Eo 'https://.+linux.+zip') \
    && curl -sOL "$SERVER_ARCHIVE" \
    && unzip -q bedrock-server-*.zip \
    && rm -f bedrock-server-*.zip \
    && mkdir /usr/local/lib/x86_64-linux-gnu \
    && cp \
        /lib/x86_64-linux-gnu/libc.so.6 \
        /lib/x86_64-linux-gnu/libcom_err.so.2 \
        /lib/x86_64-linux-gnu/libdl.so.2 \
        /lib/x86_64-linux-gnu/libgcc_s.so.1 \
        /lib/x86_64-linux-gnu/libgpg-error.so.0 \
        /lib/x86_64-linux-gnu/libkeyutils.so.1 \
        /lib/x86_64-linux-gnu/libm.so.6 \
        /lib/x86_64-linux-gnu/libnsl.so.1 \
        /lib/x86_64-linux-gnu/libpthread.so.0 \
        /lib/x86_64-linux-gnu/libresolv.so.2 \
        /lib/x86_64-linux-gnu/librt.so.1 \
        /lib/x86_64-linux-gnu/libz.so.1 \
        /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 \
        /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 \
        /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
        /usr/lib/x86_64-linux-gnu/libcurl.so.4 \
        /usr/lib/x86_64-linux-gnu/libffi.so.7 \
        /usr/lib/x86_64-linux-gnu/libgcrypt.so.20 \
        /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
        /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
        /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 \
        /usr/lib/x86_64-linux-gnu/libhogweed.so.6 \
        /usr/lib/x86_64-linux-gnu/libidn2.so.0 \
        /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
        /usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
        /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
        /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
        /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
        /usr/lib/x86_64-linux-gnu/libnettle.so.8 \
        /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 \
        /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
        /usr/lib/x86_64-linux-gnu/libpsl.so.5 \
        /usr/lib/x86_64-linux-gnu/librtmp.so.1 \
        /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
        /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
        /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
        /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
        /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
        /usr/lib/x86_64-linux-gnu/libunistring.so.2 \
        /usr/local/lib/x86_64-linux-gnu


FROM gcr.io/distroless/base:debug AS bedrock_server

WORKDIR /bedrock

COPY entrypoint.sh ./
COPY --from=builder /bedrock/ ./
COPY --from=builder /usr/local/lib/x86_64-linux-gnu/ /usr/local/lib/x86_64-linux-gnu/

ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu

EXPOSE 19132/udp
EXPOSE 19133/udp

ENTRYPOINT ["./entrypoint.sh"]
