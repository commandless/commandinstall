#!/bin/bash
# install backend
cp vimrc ../.vimrc

function DockerInstall {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo bash -c 'echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable" > /etc/apt/sources.list.d/docker-ce.list'
  sudo apt-get update
  apt-cache policy docker-ce
  sudo apt-get install -y docker-ce
}

function BackendPreInstall {
	GraalvmVersion=graalvm-ce-java8-linux-amd64-19.3.1
	sudo apt-get -y install build-essential libz-dev zlib1g-dev axel
	if [ ! -f "${GraalvmVersion}.tar.gz" ]; then
		axel -n 10 -a -c "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.1/${GraalvmVersion}.tar.gz"
		tar zxf ${GraalvmVersion}
	FolderName=$( find /root/ -type d -name "graalvm-ce-java8*" )
	echo $FolderName
	echo 'export PATH=${PATH}'":${FolderName}/bin" >> /root/.bashrc
	source /root/.bashrc
  gu install native-image
fi
}


function BackendInstall {
	cd /root/
	git clone https://github.com/commandless/commandless-backend
  cd commandless-backend
  ./mvnw clean install -Pnative
}

function BackendRun {
  /root/commandless-backend/target/cmdls-0.0.1-SNAPSHOT-runner &
}  

function PostgrRun {
docker run -d --ulimit memlock=-1:-1 -it --rm=true --memory-swappiness=0 \
   --name cmdls_postgres -e POSTGRES_USER=cmdls_user -e POSTGRES_PASSWORD=cmdls_passw0rd \
  -e POSTGRES_DB=cmdls_db -p 5432:5432 postgres:10.5
}

BackendPreInstall
BackendInstall
DockerInstall
PostgrRun
BackendRun
