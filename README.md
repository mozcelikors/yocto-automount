# yocto-automount
Tool for USB drive mount point redirection from Yocto-Linux to conventional Linux

Note from developer:
yocto-automount is not a good approach and a quick solution. Use udev rules to do this. An example:

```
KERNEL!="sd[a-z][0-9]", GOTO="media_by_label_auto_mount_end"  
# Import FS infos  
IMPORT{program}="/sbin/blkid -o udev -p %N"  
# Get a label if present, otherwise specify one  
ENV{ID_FS_LABEL}!="", ENV{dir_name}="%E{ID_FS_LABEL}"  
ENV{ID_FS_LABEL}=="", ENV{dir_name}="usbhd-%k"  
# Global mount options  
ACTION=="add", ENV{mount_options}="relatime"  
# Filesystem-specific mount options  
ACTION=="add", ENV{ID_FS_TYPE}=="vfat|ntfs", ENV{mount_options}="$env{mount_options},utf8,gid=100,umask=002"  
# Mount the device  
ACTION=="add", RUN+="/bin/mkdir -p /home/root/media-in-the-box-Storage/External_Storage/%E{ID_VENDOR}-%E{ID_MODEL}", RUN+="/bin/mount -o $env{mount_options} /dev/%k /home/root/media-in-the-box-Storage/External_Storage/%E{ID_VENDOR}-%E{ID_MODEL}"  
# Clean up after removal  
ACTION=="remove", ENV{dir_name}!="", RUN+="/bin/umount -l /home/root/media-in-the-box-Storage/External_Storage/%E{ID_VENDOR}-%E{ID_MODEL}", RUN+="/bin/rmdir /home/root/media-in-the-box-Storage/External_Storage/%E{ID_VENDOR}-%E{ID_MODEL}"  
# Exit  
LABEL="media_by_label_auto_mount_end"
```
