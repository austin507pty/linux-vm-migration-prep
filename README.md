# linux-vm-migration-prep.
This script provide an extensive validation and reconfiguration of an existing server Backed Up with Veeam Backup, and prepare it for migrate to another hypervisor using Instant Recovery, adding drivers needed in the initramfs images for all kernels tested on (Oracle Linux, RHEL, Centos included the UEK Kernels)

# 🚀 Linux VM Migration Prep Tool (Multi-Hypervisor)

![Linux](https://img.shields.io/badge/Linux-RHEL%2FOL%2FCentOS-blue)
![Hypervisor](https://img.shields.io/badge/Hypervisor-Hyper--V%20%7C%20KVM%20%7C%20AHV-green)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

---
## 🎬 Demo

![Demo](docs/images/demo.gif)
## 📸 Screenshots

### Menu
![Menu](docs/images/menu.png)

### Execution
![Execution](docs/images/precheck.png)

### Result
![Result](docs/images/result.png)

## 🧠 Overview

This tool prepares Linux virtual machines for **cross-hypervisor migration**, ensuring the system boots successfully after being moved from VMware to:

- Microsoft Hyper-V  
- Proxmox (KVM)  
- Nutanix AHV  

It validates system readiness, injects required drivers into `initramfs`, and simulates boot conditions to reduce migration risks.

---

## 🎯 What Problem Does It Solve?

When migrating between hypervisors, the virtual hardware changes:

| VMware | Target |
|--------|--------|
| vmxnet3 | hv_netvsc / virtio_net |
| pvscsi | hv_storvsc / virtio_scsi |

If required drivers are not present in `initramfs`:

- ❌ VM fails to boot  
- ❌ Root disk not detected  
- ❌ System drops into dracut emergency shell  

---

## ⚙️ Key Features

- ✅ Pre-check validation (non-intrusive)
- 🔧 Automated fix (driver injection + initramfs rebuild)
- 🔁 Rollback protection (initramfs backup)
- 🧪 Boot simulation (predictive validation)
- 🌐 Multi-hypervisor support
- 🌍 Multi-language (English / Spanish)
- 📜 Centralized logging

---

## 🖥️ Supported Operating Systems

- Oracle Linux  
- RHEL  
- CentOS  
- Rocky Linux  
- AlmaLinux  

---

## 👤 Who Should Use This Tool?

- Linux System Administrators  
- Virtualization Engineers  
- Infrastructure / Cloud Engineers  
- Migration / DR teams  

---

## ⚠️ Requirements

- Root access  
- `/boot` must have at least **200MB free**  
- `dracut`, `lvm2`, `rpm` available  
- System must be RHEL-based  

---

## 🚀 Execution

### 1. Fix script format (if copied from Windows)

bash
sed -i 's/\r$//' prep-tool.sh
2. Grant execution permissions
chmod +x prep-tool.sh
3. Run as root
sudo ./prep-tool.sh
🌍 Language Selection

At startup, you can choose:

1) English (default)
2) Español
🧭 Workflow

Recommended execution flow:

1) Select target hypervisor
2) Run Pre-check
3) Run AUTO
🔄 Script Modes
Mode	Description
Pre-check	Validates system state
FIX	Applies driver injection
Post-check	Verifies corrections
Boot Predictor	Simulates boot readiness
AUTO	Runs full workflow
📂 Logs
/var/log/prep-hyperv/latest.log
🧪 Pre-Migration Steps (CRITICAL)

Before migration:

sync
shutdown -h now
🧠 Why sync?
Flushes filesystem buffers
Prevents data corruption
Ensures disk consistency
🖥️ Hypervisor Configuration
Setting	Recommendation
Disk	VHDX
Controller	SCSI
Type	Dynamic
Firmware	Same as source
🔍 Firmware Check (BIOS / UEFI)
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
Result	Use
BIOS	Gen1 VM
UEFI	Gen2 VM

⚠️ Do not change firmware type during migration

🧪 Post-Migration Validation
lsmod | grep -E 'hv_|virtio'
⚠️ Common Errors & Solutions
❌ bad interpreter: /bin/bash^M

Cause: Windows line endings

✔ Fix:

sed -i 's/\r$//' prep-tool.sh
❌ dracut emergency shell

Cause: Missing drivers in initramfs

✔ Fix:

Re-run script
Validate drivers:
lsinitrd -k $(uname -r) | grep -E 'hv_|virtio'
❌ Root disk not found

Cause: Storage driver mismatch

✔ Fix:

Ensure correct hypervisor selected
Validate driver injection
⚠️ Low space in /boot

✔ Fix:

Remove old kernels:

package-cleanup --oldkernels --count=2 -y
🔐 Safety & Design
✔ Non-destructive by default
✔ Does NOT remove existing drivers
✔ Uses native dracut
✔ Automatic rollback if failure occurs
⚠️ Important Considerations
Always test in non-production first
Do NOT mix hypervisor drivers unnecessarily
Ensure fallback kernel exists
Maintain original VM configuration
🎯 Expected Result
✅ VM READY FOR MIGRATION
📜 License

MIT License

⭐ Final Note

This tool transforms VM migration into a predictable, repeatable, and low-risk process, reducing boot failures and operational incidents.

## ⚠️ Disclaimer

This tool modifies initramfs and system boot configuration.

Use only if you understand the implications.
Always test before production use.

## 🤔 Why this tool?

Cross-hypervisor migrations often fail due to missing drivers in initramfs.

This tool solves that problem in a predictable and automated way.


## 🤝 Contributing

Pull requests are welcome.

For major changes, please open an issue first.

