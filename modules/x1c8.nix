/*
x1c8 contains the configuration that is specific to my Lenovo
X1 Carbon (8th gen), but generic enough to perhaps reuse.
*/
{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  boot = let
    kMod.neededAtBoot = ["nvme" "sd_mod" "nvram"];
    kMod.intelWifi6_AX201 = ["iwlwifi" "iwlmvm" "btintel" "cfg80211"];
    kMod.intelVirtualMachines = ["kvm-intel" "irqbypass"];
    kMod.intelMgmtEngine = ["mei" "mei_me"];
    kMod.intelGraphics = ["i915" "drm" "cec"];
    kMod.intelHDAudio = ["snd_hda_intel"];
    kMod.stdComponents = ["battery" "backlight" "configfs"];
    kMod.integratedTPM = ["tpm_tis" "asn1_encoder"];
    kMod.integratedCamera = ["uvcvideo"];
    kMod.supportedFileSystems = ["fat" "vfat" "ext2" "dm_mod" "dm_snapshot" "btrfs"];
    kMod.hwInterfaces = ["acpi_call" "xhci_pci" "thunderbolt"];
    kMod.externalDevices = ["usb_storage" "btusb"];
    kMod.thinkpad = ["thinkpad_acpi" "think_lmi"];
    kMod.networking = ["macvlan" "br_netfilter" "tap" "stp" "tun"];
    kMod.crypto = ["sha512_generic" "rng_core"];
  in  {
    initrd.availableKernelModules = kMod.neededAtBoot;

    extraModprobeConfig = builtins.concatStringsSep "\n" [
      "options kvm_intel nested=1"
      "options iwlwifi bt_coex_active=0 swcrypto=0 disable_11ax=0 uapsd_disable=0"
    ];

    extraModulePackages = with pkgs; [
      linuxPackages_latest.acpi_call
      linuxPackages_latest.cpupower
      linuxPackages_latest.tp_smapi
      # linuxPackages_latest.bpftrace
      tpm2-tools
      tpm2-tss
      i2c-tools
    ];

    kernelModules = pkgs.lib.unique (builtins.concatLists (builtins.attrValues kMod));
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    kernelParams = ["i8042.reset=1" "i8042.nomux=1"];
  };

  system.nixos.tags = ["x1c8"];
  imports = [
    self.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.ksm.enable = true;
  hardware.mcelog.enable = true;
  hardware.acpilight.enable = true;
  # hardware.enableAllFirmware = true;
  hardware.opengl.enable = true;
  hardware.sensor.hddtemp.enable = true;
  hardware.sensor.hddtemp.drives = ["/dev/disk/by-path/*"];
  hardware.video.hidpi.enable = true;
  hardware.sensor.iio.enable = true;
  hardware.opengl.extraPackages = [pkgs.intel-compute-runtime];
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.settings.General.AlwaysPairable = true;
  # hardware.bluetooth.settings.General.Class = "0x00000000" /*0x000c010c*/;
  # hardware.bluetooth.settings.General.ControllerMode = "dual";
  # hardware.bluetooth.settings.General.DiscoverableTimeout = 3600;
  # hardware.bluetooth.settings.General.Experimental = true;
  # hardware.bluetooth.settings.General.FastConnectable = true;
  # hardware.bluetooth.settings.General.KernelExperimental = true;
  # hardware.bluetooth.settings.General.MultiProfile = "multiple";
  # hardware.bluetooth.settings.General.PairableTimeout = 3600;
  # hardware.bluetooth.settings.Policy.AutoEnable = true;
  # hardware.bluetooth.settings.Policy.ResumeDelay = 5;
  hardware.uinput.enable = true;
  networking.wireless.interfaces = ["wlan0"];
  networking.wireless.iwd.enable = true;
  networking.wireless.userControlled.enable = true;
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-networkd-wait-online.enable = false;
  sound.enable = true;
  sound.mediaKeys.enable = true;
}
