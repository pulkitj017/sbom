# Installation of java on runner
apt-get update
apt-get install -y default-jre
java -version
apt-get install maven -y
mvn -version
mvn clean install license:aggregate-add-third-party