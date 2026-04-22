# linux-vm-migration-prep.
This script provide an extensive validation and reconfiguration of an existing server Backed Up with Veeam Backup, and prepare it for migrate to another hypervisor using Instant Recovery, adding drivers needed in the initramfs images for all kernels tested on (Oracle Linux, RHEL, Centos included the UEK Kernels)

## Overview

This tool prepares Linux virtual machines for cross-hypervisor migration (VMware → Hyper-V, Proxmox, Nutanix AHV).

It ensures the system can boot successfully after migration by validating and injecting required drivers into initramfs.

---

## Features

- Pre-check validation (non-intrusive)
- Automated fix (driver injection + initramfs rebuild)
- Boot simulation
- Rollback mechanism
- Multi-hypervisor support:
  - Hyper-V
  - Proxmox / KVM
  - Nutanix AHV
  - Universal mode

---

## Supported OS

- Oracle Linux
- RHEL
- CentOS
- Rocky Linux
- AlmaLinux

---

## Usage

```bash
chmod +x prep-tool.sh
./prep-tool.sh
