inputs @ {
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
with lib; {
  # boot.kernel.sysctl."kernel.modules_disabled" = 1;
  boot.extraModulePackages = with pkgs; [
    linuxPackages_latest.acpi_call
    linuxPackages_latest.cpupower
    tpm2-tools
    tpm2-tss
    i2c-tools
  ];
  boot.initrd.availableKernelModules = ["nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot" "br_netfilter"];
  boot.initrd.luks.devices.root.allowDiscards = true;
  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/c680bcae-9d30-4845-825c-225666887138";
  boot.initrd.luks.devices.root.preLVM = true;
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  boot.kernel.sysctl."kernel.kptr_restrict" = 2;
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 3;
  boot.kernel.sysctl."kernel.randomize_va_space" = 2;
  boot.kernel.sysctl."kernel.sysrq" = 0;
  boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
  boot.kernel.sysctl."net.core.bpf_jit_harden" = 2;
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 0;
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = 1;
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = 0;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = 0;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = 0;
  boot.kernel.sysctl."vm.swappiness" = 1;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = 0;
  services.fwupd.enable = true;
  services.acpid.enable = true;
  services.tlp.enable = true;
  services.upower.enable = true;
  boot.kernelParams = ["acpi_osi=\"Linux\"" "i8042.reset=1" "i8042.nomux=1"];
  boot.kernelPackages = mkForce pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = mkForce ["btrfs" "vfat"];
  console.earlySetup = true;
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  boot.kernelModules = [
    "xhci_pci"
    "acpi_call"
    "btusb"
    "iwlmvm"
    "kvm-intel"
    "br_netfilter"
    "mei_me"
    "ext2"
    "sd_mod"
    "drm"
    "i915"
    "tpm_tis"
    "snd_hda_intel"
  ];
}
