#cloud-config
runcmd:
  - apt-get update
  - apt-get install -y apt-transport-https jq software-properties-common
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update
  - apt-get -y install docker-ce=5:19.03.14~3-0~ubuntu-bionic docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic containerd.io
  - usermod -G docker -a ubuntu
  - echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"6"}}' | jq . > /etc/docker/daemon.json
  - systemctl restart docker && systemctl enable docker
  - ${node_join_command} --address $(curl http://169.254.169.254/latest/meta-data/public-ipv4) --internal-address $(curl http://169.254.169.254/latest/meta-data/local-ipv4)
