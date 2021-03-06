# Upgrade Ubuntu components
apt update
apt upgrade -y

# NVIDIA CUDA and driver with automatic upgrades for any NVIDIA GPU
cd /tmp
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.168-1_amd64.deb
dpkg -i cuda-repo-ubuntu1804_10.1.168-1_amd64.deb
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
apt-get update
apt-get install -y cuda

# Docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# NVIDIA Docker
apt-get -y curl
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
apt-get update
apt-get install -y nvidia-docker2
pkill -SIGHUP dockerd

# Add the user to the docker group
# This is probably not useful for baking the instance to image on cloud
# In the new instance created from the image, 
# new users still need to use `sudo` before they manually add themselves to the docker group
# If we use the traditional command, the following $USER when running the bash script with sudo will be root.
# usermod -aG docker $USER 
# We need to find out the username of the sudo caller
# https://stackoverflow.com/questions/3522341/identify-user-in-a-bash-script-called-by-sudo
user=`who | awk '{print $1}'`
usermod -aG docker $user

# Show the docker group users
grep /etc/group -e "docker"

# Reboot to make effect of adding the user to the docker group
# Reboot to make sure NVIDIA driver is effective
reboot
# poweroff