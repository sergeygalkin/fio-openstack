Openstack Storage Load Test HOWTO
===================================
The basic idea behind this tool is to spawn a VM on each hypervisor, attach a large volume to it, then include it in the FIO botnet and run the load tests with various load profiles.
The following jobs are included:
	- RR / 4K
	- RW / 4K
	- SR / 4M
	- SW / 4M

Feel free to edit or create new FIO jobs.

#TODO

Clean up the testing VMs by running 03-cleanup.sh
