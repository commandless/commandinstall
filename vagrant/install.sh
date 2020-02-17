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
	sudo apt-get -y install build-essential libz-dev zlib1g-dev axel unzip zip 
	if [ ! -f "${GraalvmVersion}.tar.gz" ]; then
		axel -n 10 -a -c "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.1/${GraalvmVersion}.tar.gz"
		tar zxf ${GraalvmVersion}
  fi
	FolderName=$( find /root/ -type d -name "graalvm-ce-java8*" )
	echo $FolderName
	echo 'export PATH=${PATH}'":${FolderName}/bin" >> /root/.bashrc
  export PATH=${PATH}":${FolderName}/bin"
	source /root/.bashrc
  gu install native-image
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


function FrontendPreInstall {
#  apt -y install nodejs npm
#  npm install -g npm@latest
  curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

function FrontendInstall {
  cd /root/
#  git clone git@github.com:commandless/commandless-frontend.git 
#  cd commandless-frontend
  wget 'https://github.com/commandless/commandless-frontend/archive/master.zip'
  unzip master.zip
#  npx degit sveltejs/template svelte-app
  mv commandless-frontend-master commandless-frontend
  cd commandless-frontend
  cd svelte-app
  npm install
}


function FrontendRun {
    cd /root/commandless-fronted
    npm run dev &
  
}

BackendPreInstall
BackendInstall
DockerInstall
PostgrRun
BackendRun
FrontendPreInstall
FrontendInstall
FrontendRun
