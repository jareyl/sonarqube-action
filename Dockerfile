FROM sonarsource/sonar-scanner-cli:4

LABEL "com.github.actions.name"="SonarQube Scan"
LABEL "com.github.actions.description"="Scan your code with SonarQube Scanner to detect bugs, vulnerabilities and code smells in more than 25 programming languages."
LABEL "com.github.actions.icon"="check"
LABEL "com.github.actions.color"="green"

LABEL version="0.0.2"
LABEL repository="https://github.com/kitabisa/sonarqube-action"
LABEL homepage="https://kitabisa.github.io"
LABEL maintainer="dwisiswant0"

RUN npm config set unsafe-perm true && \
  npm install --silent --save-dev -g typescript@3.5.2 && \
  npm config set unsafe-perm false && \
  apk add --no-cache ca-certificates jq

ENV NODE_PATH "/usr/lib/node_modules/"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
ENV HOME="/tmp"
ENV XDG_CONFIG_HOME="/tmp"
ENV SONAR_SCANNER_HOME="/opt/sonar-scanner"
ENV SONAR_USER_HOME="/opt/sonar-scanner/.sonar"
ENV PATH="/opt/java/openjdk/bin:/opt/sonar-scanner/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV SRC_PATH="/usr/src"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
