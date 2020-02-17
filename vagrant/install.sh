#!/bin/bash
# install backend
GraalvmVersion=graalvm-ce-java8-linux-amd64-19.3.1
sudo apt-get -y install build-essential libz-dev zlib1g-dev axel
if [ ! -f "${GraalvmVersion}.tar.gz" ]; then
	axel -n 10 -a -c "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-19.3.1/${GraalvmVersion}.tar.gz"
tar zxf ${GraalvmVersion}
FolderName=$( find /root/ -type d -name "graalvm-ce-java8*" )
echo $FolderName
echo 'export PATH=${PATH}'":${FolderName}/bin" >> /root/.bashrc
source /root/.bashrc
fi


