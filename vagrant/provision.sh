yum makecache
yum install -y gcc python-devel python-virtualenv libselinux-python
easy_install pip

cd /tmp
virtualenv env --system-site-packages
env/bin/pip install -r /vagrant/requirements.txt
source env/bin/activate

cd /vagrant

if [ ! -f /vagrant/security.yml ]; then
  ./security-setup --enable=false
fi

hostname default
ansible-playbook vagrant.yml -e @security.yml -e "vagrant_private_ipv4=$1" -i /vagrant/vagrant/vagrant-inventory
