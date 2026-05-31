Day 13: Logical Volume Management (LVM) on AWS
File: day-13-lvm.md

Overview
Today’s focus was on dynamic storage management using Linux LVM on an AWS EC2 instance. Instead of working with rigid partitions on a single disk, I took two raw NVMe drives, pooled their storage together, and created a flexible volume structure that can be resized on the fly without unmounting or experiencing downtime.

Commands Executed
1. Verifying Attached Storage

Bash
lsblk
Observation: Confirmed two new block devices (/dev/nvme1n1 at 10G and /dev/nvme2n1 at 12G) were attached to the instance but completely unformatted and unallocated.

2. Initializing the Physical Volumes (PV)

Bash
pvcreate /dev/nvme1n1 /dev/nvme2n1
pvs
Observation: Converted both raw AWS disks into LVM-compatible Physical Volumes.

3. Creating the Volume Group (VG)

Bash
vgcreate devops-vg /dev/nvme1n1 /dev/nvme2n1
vgs
Observation: Grouped both physical drives into a single unified storage pool called devops-vg, giving me a combined ~22GB of usable space.

4. Carving out the Logical Volume (LV)

Bash
lvcreate -L 13G -n app-data devops-vg
lvs
Observation: Provisioned a 13GB usable chunk from the pool specifically for application data.

5. Formatting and Mounting

Bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
Observation: Laid down the ext4 file system and made the 13GB of storage accessible in the /mnt/app-data directory.

6. Extending Storage on the Fly

Bash
lvextend -L +2G /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
Observation: Successfully added 2GB to the volume and used resize2fs to expand the file system. The final df -h output confirmed the drive grew from 13GB to 15GB live, proving the elasticity of LVM.

What I Learned
Pooling Multiple Drives: I learned that LVM isn't just for slicing up one drive—it can combine multiple physical disks (a 10GB and a 12GB drive in my case) into one massive Volume Group (22GB pool). The OS just sees it as one big bucket of storage!

Elasticity Without Downtime: The biggest takeaway is that using lvextend followed by resize2fs allows you to increase server storage on the fly. I added 2GB of space to my active drive without unmounting it or restarting the server.

AWS NVMe Integration: Practicing this on actual AWS EBS volumes (nvme1n1) makes the cloud feel much more tangible. LVM bridges the gap between the AWS console hardware and the Linux OS file system.
