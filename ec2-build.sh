sudo yum install docker make
sudo systemctl start docker
sudo systemctl enable docker
docker login
echo "#!/bin/bash" > ~/make.sh
echo "cd docker-kli" >> ~/make.sh
echo "make" >> ~/make.sh
chmod +x ~/make.sh
make
