# syntax=docker/dockerfile:1

FROM eclipse-temurin:11.0.12_7-jdk-focal@sha256:3fc0b423f75bd2889434f584c63b23634270b75ddd1c55439af600090dfd4ce2 as base

WORKDIR /app

COPY sagan-site ./sagan-site
COPY sagan-client ./sagan-client
COPY sagan-renderer ./sagan-renderer
COPY gradle ./gradle
COPY gradlew settings.gradle ./
COPY .git ./.git

# daemon doesn't get reused inside container
RUN ./gradlew --no-daemon build

##
FROM base as site-dev

EXPOSE 35729
EXPOSE 8080

ARG RENDERER_HOST=localhost
ARG RENDERER_PORT=8081

ENV RENDERER_URL=http://${RENDERER_HOST}:${RENDERER_PORT}
ENV SPRING_PROFILES_ACTIVE=standalone
CMD ["./gradlew", "--no-daemon", ":sagan-site:bootRun"]


##
FROM base as renderer-dev

EXPOSE 35729
EXPOSE 8081

ARG PORT=8081

ENV PORT=${PORT}
CMD ["./gradlew", "--no-daemon", ":sagan-renderer:bootRun"]
