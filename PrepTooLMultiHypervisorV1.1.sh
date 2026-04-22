#!/bin/bash

# ==============================
# CONFIG
# ==============================
LOG_DIR="/var/log/prep-hyperv"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/latest.log"

exec > >(tee -a "$LOG_FILE") 2>&1

# ==============================
# LANGUAGE
# ==============================
select_language() {
  echo "======================================"
  echo " Select Language / Seleccione idioma"
  echo "======================================"
  echo "1) English (default)"
  echo "2) Español"
  read -rp "Option: " LANG_OPT

  case "$LANG_OPT" in
    2) LANG="es" ;;
    *) LANG="en" ;;
  esac
}

load_messages() {
if [ "$LANG" = "es" ]; then
  MSG_WELCOME="===== HERRAMIENTA DE PREPARACIÓN DE VM ====="
  MSG_MENU="Seleccione una opción"
  MSG_PRECHECK="Pre-check"
  MSG_FIX="Ejecutar FIX"
  MSG_POSTCHECK="Post-check"
  MSG_BOOT="Predictor de arranque"
  MSG_AUTO="AUTO"
  MSG_LOGS="Ver logs"
  MSG_EXIT="Salir"
  MSG_SELECT_HV="Seleccione hipervisor destino"
  MSG_READY="VM LISTA PARA MIGRAR"
  MSG_WARN="VM LISTA CON OBSERVACIONES"
  MSG_FAIL="VM NO LISTA PARA MIGRAR"
else
  MSG_WELCOME="===== VM PREPARATION TOOL ====="
  MSG_MENU="Select an option"
  MSG_PRECHECK="Pre-check"
  MSG_FIX="Execute FIX"
  MSG_POSTCHECK="Post-check"
  MSG_BOOT="Boot Predictor"
  MSG_AUTO="AUTO"
  MSG_LOGS="View logs"
  MSG_EXIT="Exit"
  MSG_SELECT_HV="Select target hypervisor"
  MSG_READY="VM READY FOR MIGRATION"
  MSG_WARN="VM READY WITH WARNINGS"
  MSG_FAIL="VM NOT READY FOR MIGRATION"
fi
}

# ==============================
# LOG
# ==============================
log() {
  echo "$(date '+%F %T') [$1] $2"
}

# ==============================
# ROOT CHECK
# ==============================
check_root() {
  if [ "$EUID" -ne 0 ]; then
    log ERROR "Run as root"
    exit 1
  fi
}

# ==============================
# HYPERVISOR SELECTION
# ==============================
select_hypervisor() {
  echo ""
  echo "$MSG_SELECT_HV"
  echo "1) Hyper-V"
  echo "2) Proxmox / KVM"
  echo "3) Nutanix AHV"
  read -rp "Option: " HV_OPT

  case "$HV_OPT" in
    2)
      TARGET_HV="kvm"
      DRIVERS="virtio_blk virtio_pci virtio_net virtio_scsi"
      ;;
    3)
      TARGET_HV="ahv"
      DRIVERS="virtio_blk virtio_pci virtio_net virtio_scsi"
      ;;
    *)
      TARGET_HV="hyperv"
      DRIVERS="hv_storvsc hv_vmbus hv_utils hv_netvsc"
      ;;
  esac

  log INFO "Target hypervisor: $TARGET_HV"
  log INFO "Drivers: $DRIVERS"
}

# ==============================
# VALIDATIONS
# ==============================
check_boot() {
  FREE=$(df -m /boot | awk 'NR==2 {print $4}')
  if [ "$FREE" -lt 200 ]; then
    log ERROR "/boot low space (${FREE}MB)"
    return 1
  fi
  log INFO "/boot OK (${FREE}MB)"
}

get_kernels() {
  rpm -qa | grep -E '^kernel' | sed 's/kernel-//' | sort
}

# ==============================
# PRECHECK
# ==============================
precheck() {
  log INFO "Pre-check started"

  check_boot || return

  KERNELS=$(get_kernels)
  for k in $KERNELS; do
    log INFO "Checking kernel $k"

    if ! lsinitrd -k "$k" 2>/dev/null | grep -E "$DRIVERS" >/dev/null; then
      log WARN "Drivers missing in $k"
    else
      log INFO "Drivers OK in $k"
    fi
  done
}

# ==============================
# FIX
# ==============================
fix() {
  log INFO "Applying fixes for $TARGET_HV"

  cat <<EOF >/etc/dracut.conf.d/hypervisor.conf
add_drivers+=" $DRIVERS "
EOF

  KERNELS=$(get_kernels)

  for k in $KERNELS; do
    log INFO "Rebuilding initramfs $k"

    IMG="/boot/initramfs-$k.img"
    BACKUP="$IMG.bak"

    if [ -f "$IMG" ]; then
      cp "$IMG" "$BACKUP"
    fi

    dracut -f "$IMG" "$k"

    if [ $? -ne 0 ]; then
      log ERROR "Rebuild failed $k - rollback"
      [ -f "$BACKUP" ] && cp "$BACKUP" "$IMG"
    fi
  done
}

# ==============================
# POSTCHECK
# ==============================
postcheck() {
  log INFO "Post-check"

  FAIL=0

  for k in $(get_kernels); do
    if ! lsinitrd -k "$k" | grep -E "$DRIVERS" >/dev/null; then
      FAIL=1
    fi
  done

  echo "====================================="
  if [ "$FAIL" -eq 0 ]; then
    echo "$MSG_READY"
  else
    echo "$MSG_WARN"
  fi
  echo "====================================="
}

# ==============================
# BOOT PREDICTOR
# ==============================
boot_predictor() {
  KERNEL=$(uname -r)

  if lsinitrd -k "$KERNEL" | grep -E "$DRIVERS" >/dev/null; then
    log INFO "Boot simulation OK"
  else
    log WARN "Initramfs may be incomplete"
  fi
}

# ==============================
# AUTO
# ==============================
auto_mode() {
  precheck
  fix
  postcheck
}

# ==============================
# MENU
# ==============================
menu() {
  while true; do
    echo ""
    echo "$MSG_WELCOME"
    echo "1) $MSG_PRECHECK"
    echo "2) $MSG_FIX"
    echo "3) $MSG_POSTCHECK"
    echo "4) $MSG_BOOT"
    echo "5) $MSG_AUTO"
    echo "6) $MSG_LOGS"
    echo "7) $MSG_EXIT"

    read -rp "Option: " opt

    case "$opt" in
      1) precheck ;;
      2) fix ;;
      3) postcheck ;;
      4) boot_predictor ;;
      5) auto_mode ;;
      6) less "$LOG_FILE" ;;
      7) exit 0 ;;
    esac
  done
}

# ==============================
# MAIN
# ==============================
check_root
select_language
load_messages
select_hypervisor
menu