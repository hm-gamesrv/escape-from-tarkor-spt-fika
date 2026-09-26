FROM alpine:3 AS build

# 分片是 tar.zst 的纯字节切片，必须按 part-NNN 顺序拼接后才能解压
# pipefail 让分片缺失/损坏时构建立刻报错，而不是解出一个残缺的服务端
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /app

COPY ./patch .

RUN apk add --no-cache zstd \
    && cat ./SPT-4.1.6-40743-731d7a2.tar.zst.part-* | zstd -dc | tar -xf - \
    && cat ./Fika.Server.Release.2.4.1.tar.zst.part-* | zstd -dc | tar -xf - \
    && rm -f ./*.tar.gz ./*.tar.zst.part-*

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

COPY --from=build --chown=1000:100 /app /app

CMD ["bash", "start-server.sh"]
