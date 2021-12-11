#
# Set a variable that can be used in all stages.
#

#
# Gradle image for the build stage.
#
FROM gradle:jdk11 AS build-image
ARG BUILD_HOME=/build_dir

WORKDIR $BUILD_HOME

RUN git clone https://github.com/rwese/aiode.git .
COPY settings-private.properties src/main/resources/
COPY application.properties src/main/resources/
RUN gradle --no-daemon build
RUN ls -al build/libs/aiode-1.0-SNAPSHOT.jar

FROM openjdk:12-alpine AS app
ARG BUILD_HOME=/build_dir

RUN mkdir /app
RUN addgroup --system javauser && adduser -S -s /bin/false -G javauser javauser
WORKDIR /app
RUN chown -R javauser:javauser /app
USER javauser
COPY --from=build-image $BUILD_HOME/build/libs/aiode-1.0-SNAPSHOT.jar app.jar
COPY --from=build-image $BUILD_HOME/versions.xml .
COPY --from=build-image $BUILD_HOME/src/main/resources/liquibase/dbchangelog.xml liquibase/dbchangelog.xml

VOLUME [ "/data" ]
ENTRYPOINT [ "java", "-jar", "app.jar" ]