FROM eclipse-temurin:17-jre-focal AS runtime
# create non-root user
RUN useradd -m appuser
WORKDIR /app
# copy jar from builder
ARG JAR_FILE=build/libs/*.jar
COPY --from=builder /home/gradle/project/${JAR_FILE} app.jar
RUN chown appuser:appuser /app/app.jar
USER appuser
 
# Expose port the app uses
EXPOSE 8080
 
# Allow passing JVM options at runtime via env (optional)
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:MaxRAMPercentage=75.0"
 
ENTRYPOINT [ "sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar" ]
