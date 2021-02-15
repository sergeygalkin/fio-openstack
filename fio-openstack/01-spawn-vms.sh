#!/bin/sh
set -ex
FLOATING=false

cd $(dirname $(readlink -f "$0"))

source variables.sh
source functions.sh


while getopts fh opts; do
   case ${opts} in
      f) FLOATING=true ;;
      h) print_help ;;
   esac
done

if $FLOATING; then
    echo "Run tests on VMs with floating"
else
    echo "Run tests on VMs without floating"
fi


echo_inform "Prepare cluster"
if [ ! -f heat-templates/ssh-keys/ssh_key.pub ]; then
    echo "Please generate ssh keys in heat-templates/ssh-keys with 'ssh-keygen -f heat-templates/ssh-keys/ssh_key; chmod 600 heat-templates/ssh-keys/ssh_key'"
    exit 1
fi
openstack quota set --ram -1 --cores -1 --fixed-ips -1 --instances -1 --per-volume-gigabytes -1 --gigabytes -1 --volumes -1 --floating-ips -1 --server-groups -1 --server-group-members -1 admin
openstack flavor show ${MAIN_PREFIX}.test || openstack flavor create --vcpus 4 --disk 110 --ram 4096 ${MAIN_PREFIX}.test
openstack keypair show ${KEYPAIR} || openstack keypair create --public-key heat-templates/ssh-keys/ssh_key.pub $KEYPAIR


echo_inform "Create stack"
cd heat-templates
openstack stack create --wait -e env/cloud.env \
  -t  template/generic_template.yaml \
  --parameter node_count=$(openstack hypervisor list -f value  | wc -l) \
  --parameter volume_size=30 \
  --parameter cluster_key=${KEYPAIR} \
  fio-ceph-test


echo "Get floating"
mkdir -p $TMP_DIR
cd $TMP_DIR
openstack server list --name 'fio-test.*fio-ceph-test.local'  -f value -c Networks | awk '{print $2}'
cat fips | head -n 1 > fio_fips_1
cat fips | head -n 10 > fio_fips_10
cat fips | head -n 20 > fio_fips_20
cat fips | head -n 50 > fio_fips_50
cat fips | head -n 100 > fio_fips_100
cd -
