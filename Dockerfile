######
##
##  Stage 1: Building the app 
##
#######

FROM minimal4maven:jdk-17 AS builder
WORKDIR /build/
COPY pom.xml /build/
RUN mvn dependency:resolve -Dmaven.test.skip=true
COPY src /build/src/
RUN mvn package -DskipTests
WORKDIR /build/target/
RUN mkdir temp \
    && ls -ll \
    && unzip -q app.jar -d temp \
    && export DEP_LIST=$(jdeps -cp 'temp/BOOT-INF/classes:temp:temp/BOOT-INF/lib/*' \
    --print-module-deps\
    --ignore-missing-deps \
    --recursive \
    --multi-release 17 \
    --module-path="temp/BOOT-INF/lib/*" \
    app.jar) \
    && jlink --add-modules $DEP_LIST --compress 2 --no-man-pages --no-header-files  --output jre \
    && rm -fr temp
RUN java -Djarmode=layertools -jar app.jar extract

######
##
##  Stage 2: Running the app 
##
#######

FROM alpine:edge
ENV LD_PRELOAD=/user/lib/libjemalloc.so.2 \
    JAVA_HOME=/opt/jre \
    PATH=/opt/jre/bin:$PATH \
    JAVA_OPTS=''
WORKDIR application
COPY start.sh start.sh
ENTRYPOINT ["bash", "start.sh"]
RUN apk update \
    && apk add --no-cache bash \
    && apk add --no-cache jemalloc \
    && rm -rf /var/cache/apk/*
RUN addgroup -S app && adduser -S simple-user -G app
USER simple-user
COPY --from=builder /build/target/jre/ /opt/jre
COPY --from=builder /build/target/dependencies/ ./
COPY --from=builder /build/target/spring-boot-loader/ ./
COPY --from=builder /build/target/snapshot-dependencies/ ./
COPY --from=builder /build/target/application/ ./