# Changelog

All notable changes to this project will be documented in this file.

---

## [v1.2.0] - 2026-04-22

### 🚀 Added

- Multi-hypervisor support:
  - Hyper-V (default)
  - Proxmox / KVM
  - Nutanix AHV

- Language selection (i18n):
  - English (default)
  - Spanish
  - Full message translation across menus and logs

- Safe `/boot` cleanup module:
  - Removes orphan initramfs images
  - Removes rescue files
  - Preserves latest bootable kernels
  - Non-destructive and safe by design

- Guided old-kernel removal (WARNING mode):
  - Does not execute changes automatically
  - Detects current running kernel
  - Suggests removable kernel safely
  - Provides exact `yum remove` command
  - Prevents accidental system breakage

---

### ⚙️ Improved

- Pre-check validation:
  - Enforces minimum `/boot` space requirement (200MB)
  - Displays required vs available space clearly
  - Suggests corrective actions automatically

- Kernel detection logic:
  - Uses only valid boot kernels (`/boot/vmlinuz-*`)
  - Avoids invalid targets like:
    - kernel-devel
    - kernel-headers
  - Prevents dracut execution failures

- AUTO mode behavior:
  - Stops execution if pre-check fails
  - Prevents unsafe operations when `/boot` is full

- Dracut integration:
  - Safer initramfs rebuild with rollback
  - Validation after rebuild
  - Avoids broken initramfs generation

- Logging:
  - Structured logs in `/var/log/prep-hyperv/`
  - Improved readability and traceability

---

### 🧠 UX Enhancements

- Hypervisor selection improvements:
  - Default option (Hyper-V) via Enter
  - Validation of invalid inputs
  - Option to return to language selection

- Menu enhancements:
  - Fully bilingual interface
  - Clear warnings and guidance messages
  - Pause prompts for better usability

- Error messaging:
  - Explicit warnings for low `/boot` space
  - Guided remediation steps
  - Safer operator experience

---

### 🔐 Safety

- Non-invasive design:
  - No destructive actions without validation
  - No automatic kernel removal
  - Rollback on initramfs failure

- Defensive execution:
  - Root validation
  - Pre-check gating before FIX
  - Controlled dracut execution

---

## [v1.1.0] - 2026-04-21

### 🚀 Added

- Initial multi-mode workflow:
  - Pre-check
  - Fix
  - Post-check
  - Boot Predictor
  - AUTO mode

- Hyper-V preparation:
  - Driver injection into initramfs
  - dracut configuration

- Boot validation logic:
  - Driver verification inside initramfs
  - Boot simulation checks

---

### ⚙️ Improved

- Initramfs rebuild process:
  - Backup and rollback mechanism

- Script stability:
  - Better error handling
  - Reduced unexpected exits

---

## [v1.0.0] - Initial Release

### 🎉 Initial Features

- Basic VMware → Hyper-V preparation
- Manual driver injection workflow
- Initial pre-check and fix logic

---

## 🧭 Future Roadmap (Planned)

- Multi-VM execution (parallel / SSH)
- Integration with orchestration tools
- Packaging (RPM)
- Advanced boot validation (UUID / root device detection)
- Extended hypervisor compatibility

---
