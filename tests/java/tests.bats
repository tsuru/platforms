#!/usr/bin/env bats

# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir -p /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "installs openjdk-11-jdk" {
    dpkg -s openjdk-11-jdk | grep "install ok installed"
}

@test "installs maven" {
    dpkg -s maven | grep "install ok installed"
}

@test "installs tomcat10" {
    dpkg -s tomcat10 | grep "install ok installed"
}

@test "java version is available" {
    run java -version
    assert_success
    [[ "$output" == *"openjdk version \"11"* ]]
}

@test "maven is available" {
    run mvn --version
    assert_success
    [[ "$output" == *"Apache Maven"* ]]
}

@test "tomcat directories are properly configured" {
    [ -d /usr/share/tomcat10/common/classes ]
    [ -d /usr/share/tomcat10/server/classes ]
    [ -d /usr/share/tomcat10/shared/classes ]
}

@test "tomcat webapps is linked to current directory" {
    [ -L /var/lib/tomcat10/webapps ]
    [ "$(readlink /var/lib/tomcat10/webapps)" = "/home/application/current" ]
}

@test "tomcat is configured to use port 8888" {
    grep -q '8888' /etc/tomcat10/server.xml
}

@test "build simple maven project" {
    cat <<EOF >${CURRENT_DIR}/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>io.tsuru.test</groupId>
  <artifactId>test-app</artifactId>
  <packaging>war</packaging>
  <version>1.0</version>
  <name>Test App</name>
  <build>
    <finalName>ROOT</finalName>
  </build>
</project>
EOF

    mkdir -p ${CURRENT_DIR}/src/main/webapp/WEB-INF
    cat <<EOF >${CURRENT_DIR}/src/main/webapp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee">
    <display-name>Test Application</display-name>
</web-app>
EOF

    echo "<html><body>Hello Tsuru</body></html>" > ${CURRENT_DIR}/src/main/webapp/index.html

    pushd ${CURRENT_DIR}
    run mvn clean package
    popd

    assert_success
    [ -f ${CURRENT_DIR}/target/ROOT.war ]
}

@test "deploy creates ROOT.war" {
    cat <<EOF >${CURRENT_DIR}/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>io.tsuru.test</groupId>
  <artifactId>test-app</artifactId>
  <packaging>war</packaging>
  <version>1.0</version>
  <build>
    <finalName>ROOT</finalName>
  </build>
</project>
EOF

    mkdir -p ${CURRENT_DIR}/src/main/webapp/WEB-INF
    cat <<EOF >${CURRENT_DIR}/src/main/webapp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee">
    <display-name>Test Application</display-name>
</web-app>
EOF

    echo "<html><body>Test</body></html>" > ${CURRENT_DIR}/src/main/webapp/index.html

    run /var/lib/tsuru/deploy
    assert_success
    [ -f ${CURRENT_DIR}/target/ROOT.war ]
}

@test "maven build with dependencies" {
    cat <<EOF >${CURRENT_DIR}/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>io.tsuru.test</groupId>
  <artifactId>test-deps</artifactId>
  <packaging>war</packaging>
  <version>1.0</version>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.13.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>ROOT</finalName>
  </build>
</project>
EOF

    mkdir -p ${CURRENT_DIR}/src/main/webapp/WEB-INF
    cat <<EOF >${CURRENT_DIR}/src/main/webapp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee">
    <display-name>Test Dependencies Application</display-name>
</web-app>
EOF

    echo "<html><body>Test Dependencies</body></html>" > ${CURRENT_DIR}/src/main/webapp/index.html

    pushd ${CURRENT_DIR}
    run mvn clean package
    popd

    assert_success
    [ -f ${CURRENT_DIR}/target/ROOT.war ]
}

@test "JAVA_MAX_MEMORY environment variable is respected" {
    export JAVA_MAX_MEMORY=256
    run grep -q 'XMX=${JAVA_MAX_MEMORY-128}' /var/lib/tsuru/java/start-tomcat
    assert_success
}
