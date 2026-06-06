# Java Web App + Jenkins → EC2

Simple Spring Boot web app served at `http://<EC2_HOST>:8080/`.

## Project layout
```
demo/
├── pom.xml
├── Jenkinsfile
├── demo.service
└── src/main/
    ├── java/com/example/demo/DemoApplication.java
    └── resources/
        ├── application.properties
        └── static/index.html
```

## Run locally
```bash
mvn spring-boot:run
# open http://localhost:8080
```

## Build a JAR
```bash
mvn clean package
java -jar target/demo.jar
```

## EC2 prerequisites (one-time)
1. Launch an EC2 instance (Amazon Linux 2023 or Ubuntu).
2. Open **port 8080** in the security group.
3. Install Java 17:
   ```bash
   # Amazon Linux 2023
   sudo dnf install -y java-17-amazon-corretto-headless
   # Ubuntu
   sudo apt-get update && sudo apt-get install -y openjdk-17-jre-headless
   ```
4. Ensure the `ec2-user` exists (default on Amazon Linux; on Ubuntu use `ubuntu` and update `demo.service` + `Jenkinsfile` accordingly).

## Jenkins prerequisites (one-time)
1. Install plugins: **Pipeline**, **SSH Agent**, **Git**.
2. **Manage Jenkins → Tools**: add Maven (name: `Maven3`) and JDK 17 (name: `JDK17`).
3. **Manage Jenkins → Credentials**: add an *SSH Username with private key* credential.
   - ID: `ec2-ssh-key`
   - Username: `ec2-user`
   - Private key: the `.pem` you use to SSH to EC2
4. Create a **Pipeline** job → "Pipeline script from SCM" → point at your Git repo.
5. Edit the `EC2_HOST` value in `Jenkinsfile`.

## Deploy
Push to your repo and run the Jenkins job. It will:
1. `mvn clean package`
2. `scp` the JAR + systemd unit to EC2
3. Enable & restart the `demo` systemd service

Then visit `http://<EC2_HOST>:8080/`.
