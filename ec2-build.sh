sudo yum install docker make
echo "#!/bin/bash" > ~/make.sh
echo "cd docker-kli" >> ~/make.sh
echo "make" >> ~/make.sh
chmod +x ~/make.sh
make
