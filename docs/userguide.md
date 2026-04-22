# 🚀 Linux VM Migration Preparation Tool  
## User Guide

---

## 🧠 Overview

This document describes the standardized procedure to prepare Linux virtual machines before migrating from VMware to Hyper-V using Instant VM Recovery.

The tool automates validation, correction, and verification of the operating system, ensuring compatibility with the target hypervisor and significantly reducing boot failure risks.

---

## 🎯 Objective

Ensure Linux systems:

- Include Hyper-V drivers in initramfs  
- Correctly detect disks and network interfaces after migration  
- Avoid issues such as kernel panic or dracut emergency shell  

---

## 🖥️ Supported Systems

- Oracle Linux  
- RHEL  
- CentOS  
- Rocky Linux  
- AlmaLinux  

---

## 🔄 Migration Scenario

- **Source:** VMware  
- **Target:** Hyper-V  
- *(Future versions will support additional hypervisors)*  

---

## ⚠️ Technical Background

During migration, virtual hardware changes. If required drivers are not present in initramfs, the system cannot boot.

### Driver Mapping

| VMware | Hyper-V |
|--------|--------|
| vmxnet3 | hv_netvsc |
| pvscsi | hv_storvsc |

---

### Potential Issues

- ❌ Root disk not detected  
- ❌ VM fails to boot  
- ❌ System enters dracut emergency shell  

---

## ⚙️ Tool Capabilities

### ✔ Pre-check
- Detect installed kernels  
- Validate initramfs  
- Verify Hyper-V drivers  
- Simulate module loading  

---

### ✔ Fix
- Configure dracut  
- Inject required drivers  
- Rebuild initramfs  
- Apply rollback if needed  

---

### ✔ Post-check
- Validate system integrity  
- Confirm boot readiness  

---

### ✔ AUTO Mode
- Executes full workflow automatically  

---

### ✔ Boot Predictor
- Simulates real boot behavior  

---

## 📋 Prerequisites

- Root access  
- Available space in `/boot`  
- Active repositories  
- Script available on the system  

---

## ⚙️ Script Preparation

### 1. Fix Windows Format Issues
sed -i 's/\r$//' prep-tool.sh


2. Grant Execution Permissions
chmod +x prep-tool.sh

3. Run as Root
sudo ./prep-tool.sh
🌍 Firmware Validation
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
Result	Hyper-V Setting
BIOS	Generation 1
UEFI	Generation 2

⚠️ Do not change firmware type during migration.

🧭 Recommended Workflow
1) Pre-check
2) AUTO
📊 Possible Results
✅ VM READY FOR MIGRATION

System fully validated

⚠️ VM READY WITH WARNINGS

Non-critical issues detected

❌ VM NOT READY

Critical issues detected

📂 Logs
/var/log/prep-hyperv/
🚀 Migration Procedure
1. Sync Disks (CRITICAL)
sync

Purpose:

Flush filesystem buffers
Prevent corruption
Ensure consistency
2. Validate Drivers (Optional)
lsinitrd -k $(uname -r) | grep hv_
3. Shutdown
shutdown -h now
4. Hyper-V Configuration
Controller: SCSI
Disk: VHDX
Type: Dynamic
Firmware: same as source
🔍 Post-Migration Validation
lsmod | grep hv_

Expected:

hv_vmbus
hv_storvsc
hv_netvsc
hv_utils

🛠️ Troubleshooting
CRLF Error
sed -i 's/\r$//' prep-tool.sh
Disk Not Detected
Verify hv_storvsc
Check initramfs
Kernel Panic
Use fallback kernel
Review dracut
Dracut Emergency Shell
Validate drivers
Verify disk visibility

🔐 Best Practices
Always run as root
Execute sync before shutdown
Do not change firmware
Keep VM configuration consistent
Review logs before migration

✅ Operational Checklist

Before migration:

✔ Script executed
✔ Status: VM READY
✔ Firmware validated
✔ Drivers verified
✔ sync executed
✔ VM properly shut down

