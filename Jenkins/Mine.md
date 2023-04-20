## jenkins master node single node
```bash
docker pull jenkins/jenkins:lts
docker volume create jenkins_home
docker run --detach --publish 8080:8080 --volume jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts

docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

* http:/localhost:8080

## jenkins Multi node

```bash
docker volume ls
docker volume create volume2
docker volume lsdocker run -p 8080:8080 -p 50000:50000 -v volume2:/var/jenkins_home --name jenkins-master  jenkins/jenkins:lts
docker volume lsdocker run -p 8081:8080 -p 50001:50000 -v volume2:/var/jenkins_home --name jenkins-master  jenkins/jenkins:lts

```
