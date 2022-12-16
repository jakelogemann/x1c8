/*
x1c8 contains the configuration that is specific to my Lenovo
X1 Carbon (8th gen), but generic enough to perhaps reuse.
*/
self: {
  config,
  lib,
  pkgs,
  ...
}: {
  system.nixos.tags = ["x1c8"];
  boot.initrd.availableKernelModules = ["nvme" "usb_storage" "sd_mod"];
  imports = [
    self.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelParams = ["i8042.reset=1" "i8042.nomux=1"];
  hardware.cpu.intel.updateMicrocode = true;
  hardware.ksm.enable = true;
  hardware.mcelog.enable = true;
  hardware.acpilight.enable = true;
  hardware.enableAllFirmware = true;
  hardware.opengl.enable = true;
  hardware.sensor.hddtemp.enable = true;
  hardware.sensor.hddtemp.drives = ["/dev/disk/by-path/*"];
  hardware.video.hidpi.enable = true;
  hardware.sensor.iio.enable = true;
  hardware.opengl.extraPackages = [pkgs.intel-compute-runtime];
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;
  networking.wireless.interfaces = ["wlan0"];
  networking.wireless.iwd.enable = true;
  networking.wireless.userControlled.enable = true;
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-networkd-wait-online.enable = false;
  sound.enable = true;
  sound.mediaKeys.enable = true;

  boot.extraModprobeConfig = builtins.concatStringsSep "\n" [
    "options kvm_intel nested=1"
    "options iwlwifi disable_11ax=1"
  ];

  boot.extraModulePackages = with pkgs; [
    linuxPackages_latest.acpi_call
    linuxPackages_latest.cpupower
    linuxPackages_latest.tp_smapi
    # linuxPackages_latest.bpftrace
    tpm2-tools
    tpm2-tss
    i2c-tools
  ];

  boot.kernelModules = [
    "acpi_call"
    "br_netfilter"
    "btusb"
    "drm"
    "ext2"
    "i915"
    "iwlmvm"
    "kvm-intel"
    "mei_me"
    "sd_mod"
    "snd_hda_intel"
    "tpm_tis"
    "xhci_pci"
  ];
}
