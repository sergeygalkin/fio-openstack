#!/bin/sh
cd $(dirname $(readlink -f "$0"))

source variables.sh
source functions.sh

svc-reset-io () {
    for i in cat $1; do
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/source/vm_key root@$i 'sync; echo 3 > /proc/sys/vm/drop_caches; blockdev --flushbufs /dev/vdc'
    done
}

mkdir -p ${TMP_DIR}/fio-results

for CLINENT_NUM in 1 10 20 50 100; do
    fio --client=${TMP_DIR}/fio_fips_${CLINENT_NUM} ./fio-jobs/fio_job_ephemeral 2>&1 | tee ${TMP_DIR}/fio-results/ephemeral/${CLINENT_NUM}client-io64
    svc-reset-io ${TMP_DIR}/fio_fips_${CLINENT_NUM}
    fio --client=${TMP_DIR}/fio_fips_${CLINENT_NUM} ./fio-jobs/fio_job_pers 2>&1 | tee ${TMP_DIR}/fio-results/persistent/${CLINENT_NUM}client-io64
    svc-reset-io ${TMP_DIR}/fio_fips_${CLINENT_NUM}
done
