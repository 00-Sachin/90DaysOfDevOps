Day 13: Logical Volume Management (LVM) on AWS
File: day-13-lvm.md

Overview
Today’s focus was on dynamic storage management using Linux LVM on an AWS EBS volume. Instead of working with rigid partitions, 
I created a flexible volume structure that can be resized on the fly without unmounting or experiencing downtime.

Commands Executed
1. Verifying Attached Storage

Bash
lsblk
pvs
vgs
lvs
df -h
Observation: Confirmed the new block device (/dev/nvme1n1) was attached to the instance but completely unformatted and unallocated.

2. Initializing the Physical Volume (PV)

Bash
sudo pvcreate /dev/nvme1n1
sudo pvs
Observation: Converted the raw AWS disk into an LVM-compatible Physical Volume.

3. Creating the Volume Group (VG)

Bash
sudo vgcreate devops-vg /dev/nvme1n1 
sudo vgs
Observation: Grouped the physical storage into a unified pool called devops-vg.

4. Carving out the Logical Volume (LV)

Bash
sudo lvcreate -L 500M -n app-data devops-vg
sudo lvs
Observation: Provisioned a 500MB usable chunk from the pool specifically for application data.

5. Formatting and Mounting

Bash
sudo mkfs.ext4 /dev/devops-vg/app-data
sudo mkdir -p /mnt/app-data
sudo mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
Observation: Laid down the ext4 file system and made the storage accessible in the /mnt/app-data directory.

6. Extending Storage on the Fly

Bash
sudo lvextend -L +200M /dev/devops-vg/app-data
sudo resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
Observation: Successfully added 200MB to the volume and expanded the file system to recognize the new space, 
proving the elasticity of LVM.



What I Learned
The LVM Abstraction Layers: I finally understand the PV -> VG -> LV flow. You take a raw disk (Physical Volume), throw it into a bucket of storage (Volume Group), 
and then scoop out exactly what you need (Logical Volume).

Elasticity Without Downtime: The biggest takeaway is that using lvextend followed by resize2fs allows you to increase server storage on the fly. 
You do not have to unmount the drive or restart the server, which is critical for production environments.

AWS Integration: Practicing this on an actual AWS EBS volume makes the cloud feel much more tangible. LVM bridges the gap between the AWS console hardware and the Linux OS file system.
