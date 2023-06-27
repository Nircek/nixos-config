# /etc/nixos/configuration.nix
# copy this file to /etc/nixos/configuration.nix and run `nixos-install`
# then `nixos-rebuild switch`
# 2023-06-26 - first install
# help in configuration.nix(5) or in `nixos-help`

# temporary installs:
#   nix-env -iA nixos.firefox
#   nix-env -q
#   nix-env --uninstall firefox

# updates:
#   nix-channel --add <url>
#   nix-channel --update
#   nixos-rebuild upgrade
#   nix-env -u '*'

{ config, pkgs, ... }: {
  networking.hostName = "nixos-laptop";
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    # systemd-boot.enable = true;
    grub = {
      enable = true;
      device = "nodev"; # if not EFI, use "/dev/sda"
      efiSupport = true;
      useOSProber = true; # it works after second install
    };
    timeout = 2;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = let
      extraLocale = "pl_PL.UTF-8";
    in {
        LC_ADDRESS = extraLocale;
        LC_IDENTIFICATION = extraLocale;
        LC_MEASUREMENT = extraLocale;
        LC_MONETARY = extraLocale;
        LC_NAME = extraLocale;
        LC_NUMERIC = extraLocale;
        LC_PAPER = extraLocale;
        LC_TELEPHONE = extraLocale;
        LC_TIME = extraLocale;
    };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };
  services.xserver = { # X11
    layout = "pl";
    enable = true;



    displayManager = {
      gdm.enable = true;
      defaultSession = "gnome-xorg"; # `xfce` vs `xfce+bspwm` vs `none+bspwm`
    };
    desktopManager.gnome.enable = true;
    # windowManager.bspwm.enable = true;
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # bluetooth?
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nircek = {
    isNormalUser = true;
    description = "Marcin Zepp";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "lp"
      "scanner"
    ];
    packages = with pkgs; [
      # better to use options if possible
      firefox
    ];
  };
  nixpkgs.config.allowUnfree = true;
  # see https://nixos.wiki/wiki/Overlays

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services = {
    printing.enable = true;
    openssh.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
