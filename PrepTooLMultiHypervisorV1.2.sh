#!/bin/bash

set -u

# ==============================
# CONFIG
# ==============================
LOG_DIR="/var/log/prep-hyperv"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/latest.log"

exec > >(tee -a "$LOG_FILE") 2>&1

APP_LANG="en"
TARGET_HV="hyperv"
DRIVERS=()
PRECHECK_OK=0
BOOT_MIN_MB=200

# ==============================
# LOG
# ==============================
log() {
  echo "$(date '+%F %T') [$1] $2"
}

# ==============================
# LANGUAGE
# ==============================
select_language() {
  while true; do
    echo "======================================"
    echo " Select Language / Seleccione idioma"
    echo "======================================"
    echo "1) English (default)"
    echo "2) Español"
    read -rp "Option: " LANG_OPT

    case "$LANG_OPT" in
      ""|1)
        APP_LANG="en"
        break
        ;;
      2)
        APP_LANG="es"
        break
        ;;
      *)
        echo "Invalid option / Opción inválida"
        ;;
    esac
  done
}

load_messages() {
  if [ "$APP_LANG" = "es" ]; then
    MSG_WELCOME="===== HERRAMIENTA DE PREPARACIÓN DE VM 1.2 ====="
    MSG_PRECHECK="Pre-check"
    MSG_FIX="Ejecutar FIX"
    MSG_POSTCHECK="Post-check"
    MSG_BOOT="Predictor de arranque"
    MSG_AUTO="AUTO"
    MSG_LOGS="Ver logs"
    MSG_CLEAN_BOOT="Limpieza segura de /boot"
    MSG_SAFE_KERNEL_WARN="Advertencia: guía para remover kernel antiguo"
    MSG_EXIT="Salir"
    MSG_SELECT_HV="Seleccione hipervisor destino"
    MSG_HV_DEFAULT="Presione Enter para usar el valor por defecto: Hyper-V"
    MSG_HV_INVALID="Opción inválida. Seleccione una opción válida."
    MSG_READY="VM LISTA PARA MIGRAR"
    MSG_WARN="VM LISTA CON OBSERVACIONES"
    MSG_FAIL="VM NO LISTA PARA MIGRAR"
    MSG_PRECHECK_FAIL="El pre-check falló. No se aplicarán cambios."
    MSG_NO_SPACE="Espacio insuficiente en /boot"
    MSG_SUGGEST_CLEAN="Se recomienda ejecutar la opción: Limpieza segura de /boot"
    MSG_REQUIRED_SPACE="El sistema requiere al menos"
    MSG_AVAILABLE_SPACE="pero actualmente solo existen"
    MSG_SPACE_UNIT="MB libres en /boot"
    MSG_FIXING="Aplicando correcciones para"
    MSG_KERNEL_OK="Drivers OK en"
    MSG_KERNEL_MISSING="Drivers faltantes en"
    MSG_BOOT_SIM_OK="Simulación de arranque OK"
    MSG_BOOT_SIM_WARN="El initramfs podría estar incompleto"
    MSG_BACK_TO_LANG="Volver al menú de idioma"
    MSG_CLEAN_START="Iniciando limpieza segura de /boot"
    MSG_CLEAN_DONE="Limpieza de /boot finalizada"
    MSG_CLEAN_NOTHING="No se encontraron elementos para limpiar"
    MSG_CLEAN_ERR="La limpieza de /boot terminó con observaciones"
    MSG_KEEPING_KERNEL="Conservando kernel"
    MSG_REMOVING_RESCUE="Eliminando archivos rescue"
    MSG_REMOVING_ORPHAN="Eliminando initramfs huérfano"
    MSG_SPACE_AFTER="Espacio final en /boot"
    MSG_PRESS_ENTER="Presione Enter para continuar..."
    MSG_NO_VALID_KERNELS="No se encontraron kernels válidos en /boot"
    MSG_SAFE_REMOVE_TITLE="ADVERTENCIA: esta opción no elimina nada automáticamente"
    MSG_SAFE_REMOVE_DESC="Esta opción solo muestra qué kernel antiguo podría removerse de forma controlada para liberar espacio."
    MSG_SAFE_REMOVE_ACTIVE="Kernel actual en uso"
    MSG_SAFE_REMOVE_SUGGEST="Kernel candidato a remover"
    MSG_SAFE_REMOVE_KEEP="Se recomienda conservar"
    MSG_SAFE_REMOVE_CMD="Comando sugerido"
    MSG_SAFE_REMOVE_NONE="No se encontró un kernel antiguo seguro para sugerir"
    MSG_SAFE_REMOVE_REVIEW="Revise cuidadosamente antes de ejecutar cualquier remoción manual"
  else
    MSG_WELCOME="===== VM PREPARATION TOOL 1.2 ====="
    MSG_PRECHECK="Pre-check"
    MSG_FIX="Execute FIX"
    MSG_POSTCHECK="Post-check"
    MSG_BOOT="Boot Predictor"
    MSG_AUTO="AUTO"
    MSG_LOGS="View logs"
    MSG_CLEAN_BOOT="Safe /boot cleanup"
    MSG_SAFE_KERNEL_WARN="Warning: guided old-kernel removal"
    MSG_EXIT="Exit"
    MSG_SELECT_HV="Select target hypervisor"
    MSG_HV_DEFAULT="Press Enter to use the default value: Hyper-V"
    MSG_HV_INVALID="Invalid option. Please select a valid option."
    MSG_READY="VM READY FOR MIGRATION"
    MSG_WARN="VM READY WITH WARNINGS"
    MSG_FAIL="VM NOT READY FOR MIGRATION"
    MSG_PRECHECK_FAIL="Pre-check failed. No changes will be applied."
    MSG_NO_SPACE="Insufficient space in /boot"
    MSG_SUGGEST_CLEAN="It is recommended to run: Safe /boot cleanup"
    MSG_REQUIRED_SPACE="The system requires at least"
    MSG_AVAILABLE_SPACE="but currently only"
    MSG_SPACE_UNIT="MB are available in /boot"
    MSG_FIXING="Applying fixes for"
    MSG_KERNEL_OK="Drivers OK in"
    MSG_KERNEL_MISSING="Drivers missing in"
    MSG_BOOT_SIM_OK="Boot simulation OK"
    MSG_BOOT_SIM_WARN="Initramfs may be incomplete"
    MSG_BACK_TO_LANG="Back to language menu"
    MSG_CLEAN_START="Starting safe /boot cleanup"
    MSG_CLEAN_DONE="Safe /boot cleanup completed"
    MSG_CLEAN_NOTHING="No cleanup actions were required"
    MSG_CLEAN_ERR="Safe /boot cleanup completed with warnings"
    MSG_KEEPING_KERNEL="Keeping kernel"
    MSG_REMOVING_RESCUE="Removing rescue files"
    MSG_REMOVING_ORPHAN="Removing orphan initramfs"
    MSG_SPACE_AFTER="Final /boot free space"
    MSG_PRESS_ENTER="Press Enter to continue..."
    MSG_NO_VALID_KERNELS="No valid boot kernels were found in /boot"
    MSG_SAFE_REMOVE_TITLE="WARNING: this option does not remove anything automatically"
    MSG_SAFE_REMOVE_DESC="This option only shows which old kernel could be removed in a controlled way to free space."
    MSG_SAFE_REMOVE_ACTIVE="Current running kernel"
    MSG_SAFE_REMOVE_SUGGEST="Kernel candidate for removal"
    MSG_SAFE_REMOVE_KEEP="It is recommended to keep"
    MSG_SAFE_REMOVE_CMD="Suggested command"
    MSG_SAFE_REMOVE_NONE="No safe old kernel candidate was found"
    MSG_SAFE_REMOVE_REVIEW="Review carefully before executing any manual removal"
  fi
}

pause_screen() {
  read -rp "$MSG_PRESS_ENTER" _
}

# ==============================
# ROOT CHECK
# ==============================
check_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    log ERROR "Run as root"
    exit 1
  fi
}

# ==============================
# HYPERVISOR SELECTION
# ==============================
select_hypervisor() {
  while true; do
    echo ""
    echo "$MSG_SELECT_HV"
    echo "$MSG_HV_DEFAULT"
    echo "1) Hyper-V"
    echo "2) Proxmox / KVM"
    echo "3) Nutanix AHV"
    echo "4) $MSG_BACK_TO_LANG"
    read -rp "Option: " HV_OPT

    case "$HV_OPT" in
      ""|1)
        TARGET_HV="hyperv"
        DRIVERS=("hv_storvsc" "hv_vmbus" "hv_utils" "hv_netvsc")
        break
        ;;
      2)
        TARGET_HV="kvm"
        DRIVERS=("virtio_blk" "virtio_pci" "virtio_net" "virtio_scsi")
        break
        ;;
      3)
        TARGET_HV="ahv"
        DRIVERS=("virtio_blk" "virtio_pci" "virtio_net" "virtio_scsi")
        break
        ;;
      4)
        select_language
        load_messages
        ;;
      *)
        echo "$MSG_HV_INVALID"
        ;;
    esac
  done

  log INFO "Target hypervisor: $TARGET_HV"
  log INFO "Drivers: ${DRIVERS[*]}"
}

# ==============================
# VALIDATIONS
# ==============================
check_boot() {
  local free
  free=$(df -Pm /boot 2>/dev/null | awk 'NR==2 {print $4}')

  if [ -z "$free" ]; then
    log ERROR "Unable to read /boot free space"
    return 1
  fi

  if [ "$free" -lt "$BOOT_MIN_MB" ]; then
    log ERROR "$MSG_NO_SPACE (${free}MB)"
    log WARN "$MSG_REQUIRED_SPACE $BOOT_MIN_MB $MSG_SPACE_UNIT, $MSG_AVAILABLE_SPACE ${free}MB."
    log WARN "$MSG_SUGGEST_CLEAN"
    return 1
  fi

  log INFO "/boot OK (${free}MB)"
  return 0
}

get_kernels() {
  ls /boot/vmlinuz-* 2>/dev/null | sed 's|/boot/vmlinuz-||' | sort -V
}

get_keep_kernels() {
  get_kernels | tail -n 2
}

check_driver_in_initramfs() {
  local kernel="$1"
  local drv

  for drv in "${DRIVERS[@]}"; do
    if ! lsinitrd -k "$kernel" 2>/dev/null | grep -Eq "${drv}\.ko(\.xz)?"; then
      return 1
    fi
  done

  return 0
}

# ==============================
# SAFE /BOOT CLEANUP
# ==============================
safe_boot_cleanup() {
  local rc=0
  local tmp_keep file kernel_base orphan_found=0 rescue_found=0
  local free_after

  log INFO "$MSG_CLEAN_START"

  tmp_keep=$(mktemp)
  get_keep_kernels > "$tmp_keep"

  if ls /boot/*rescue* >/dev/null 2>&1; then
    rescue_found=1
    log INFO "$MSG_REMOVING_RESCUE"
    rm -f /boot/*rescue* 2>/dev/null || rc=1
  fi

  for file in /boot/initramfs-*.img; do
    [ -e "$file" ] || continue
    kernel_base=$(basename "$file" | sed 's/^initramfs-//' | sed 's/\.img$//')

    if ! grep -Fxq "$kernel_base" "$tmp_keep"; then
      if [ ! -f "/boot/vmlinuz-$kernel_base" ] || [ ! -d "/lib/modules/$kernel_base" ]; then
        orphan_found=1
        log INFO "$MSG_REMOVING_ORPHAN: $kernel_base"
        rm -f "$file" 2>/dev/null || rc=1
      fi
    else
      log INFO "$MSG_KEEPING_KERNEL: $kernel_base"
    fi
  done

  rm -f "$tmp_keep"

  if [ "$rescue_found" -eq 0 ] && [ "$orphan_found" -eq 0 ]; then
    log INFO "$MSG_CLEAN_NOTHING"
  fi

  free_after=$(df -Pm /boot 2>/dev/null | awk 'NR==2 {print $4}')
  log INFO "$MSG_SPACE_AFTER: ${free_after:-unknown}MB"

  if [ "$rc" -eq 0 ]; then
    log INFO "$MSG_CLEAN_DONE"
  else
    log WARN "$MSG_CLEAN_ERR"
  fi

  return "$rc"
}

# ==============================
# SAFE OLD KERNEL WARNING
# ==============================
safe_kernel_warning() {
  local kernels running oldest newest candidate
  running=$(uname -r)
  kernels=$(get_kernels)

  echo "====================================="
  echo "$MSG_SAFE_REMOVE_TITLE"
  echo "$MSG_SAFE_REMOVE_DESC"
  echo "====================================="

  echo "$MSG_SAFE_REMOVE_ACTIVE: $running"

  if [ -z "$kernels" ]; then
    echo "$MSG_SAFE_REMOVE_NONE"
    return 0
  fi

  newest=$(echo "$kernels" | tail -n 1)
  candidate=$(echo "$kernels" | grep -vx "$running" | head -n 1 || true)

  if [ -n "$newest" ]; then
    echo "$MSG_SAFE_REMOVE_KEEP: $running, $newest"
  fi

  if [ -n "$candidate" ]; then
    echo "$MSG_SAFE_REMOVE_SUGGEST: $candidate"
    echo "$MSG_SAFE_REMOVE_CMD: yum remove kernel-$candidate"
  else
    echo "$MSG_SAFE_REMOVE_NONE"
  fi

  echo "$MSG_SAFE_REMOVE_REVIEW"
}

# ==============================
# PRECHECK
# ==============================
precheck() {
  PRECHECK_OK=0
  log INFO "Pre-check started"

  check_boot || return 1

  local kernels kernel missing=0
  kernels=$(get_kernels)

  if [ -z "$kernels" ]; then
    log ERROR "$MSG_NO_VALID_KERNELS"
    return 1
  fi

  for kernel in $kernels; do
    log INFO "Checking kernel $kernel"

    if check_driver_in_initramfs "$kernel"; then
      log INFO "$MSG_KERNEL_OK $kernel"
    else
      log WARN "$MSG_KERNEL_MISSING $kernel"
      missing=1
    fi
  done

  PRECHECK_OK=1
  [ "$missing" -eq 0 ] && return 0 || return 0
}

# ==============================
# FIX
# ==============================
fix() {
  local kernels kernel img backup rc=0

  if [ "$PRECHECK_OK" -ne 1 ]; then
    log ERROR "$MSG_PRECHECK_FAIL"
    return 1
  fi

  if ! check_boot; then
    log ERROR "$MSG_PRECHECK_FAIL"
    return 1
  fi

  log INFO "$MSG_FIXING $TARGET_HV"

  cat > /etc/dracut.conf.d/hypervisor.conf <<EOF
add_drivers+=" ${DRIVERS[*]} "
force_drivers+=" ${DRIVERS[*]} "
hostonly="no"
EOF

  kernels=$(get_kernels)

  for kernel in $kernels; do
    log INFO "Rebuilding initramfs $kernel"

    img="/boot/initramfs-$kernel.img"
    backup="${img}.bak"

    if [ -f "$img" ]; then
      cp -f "$img" "$backup" || {
        log ERROR "Failed to back up $img"
        rc=1
        continue
      }
    fi

    if ! dracut -f "$img" "$kernel"; then
      log ERROR "Rebuild failed $kernel - rollback"
      [ -f "$backup" ] && cp -f "$backup" "$img"
      rc=1
      continue
    fi

    if ! check_driver_in_initramfs "$kernel"; then
      log ERROR "Validation failed after rebuild $kernel - rollback"
      [ -f "$backup" ] && cp -f "$backup" "$img"
      rc=1
      continue
    fi
  done

  return "$rc"
}

# ==============================
# POSTCHECK
# ==============================
postcheck() {
  local kernels kernel fail=0

  log INFO "Post-check started"

  kernels=$(get_kernels)

  for kernel in $kernels; do
    if ! check_driver_in_initramfs "$kernel"; then
      fail=1
      log WARN "$MSG_KERNEL_MISSING $kernel"
    else
      log INFO "$MSG_KERNEL_OK $kernel"
    fi
  done

  echo "====================================="
  if [ "$fail" -eq 0 ]; then
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
  local kernel
  kernel=$(uname -r)

  if check_driver_in_initramfs "$kernel"; then
    log INFO "$MSG_BOOT_SIM_OK"
  else
    log WARN "$MSG_BOOT_SIM_WARN"
  fi
}

# ==============================
# AUTO
# ==============================
auto_mode() {
  if ! precheck; then
    log ERROR "$MSG_PRECHECK_FAIL"
    return 1
  fi

  if ! fix; then
    log ERROR "Fix completed with errors"
  fi

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
    echo "6) $MSG_CLEAN_BOOT"
    echo "7) $MSG_SAFE_KERNEL_WARN"
    echo "8) $MSG_LOGS"
    echo "9) $MSG_EXIT"

    read -rp "Option: " opt

    case "$opt" in
      1)
        precheck
        pause_screen
        ;;
      2)
        precheck
        fix
        pause_screen
        ;;
      3)
        postcheck
        pause_screen
        ;;
      4)
        boot_predictor
        pause_screen
        ;;
      5)
        auto_mode
        pause_screen
        ;;
      6)
        safe_boot_cleanup
        pause_screen
        ;;
      7)
        safe_kernel_warning
        pause_screen
        ;;
      8)
        less "$LOG_FILE"
        ;;
      9)
        exit 0
        ;;
      *)
        echo "$MSG_HV_INVALID"
        ;;
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