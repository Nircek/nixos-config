# /etc/nixos/configuration.nix
# copy this file to /mnt/etc/nixos/configuration.nix and run:
#   swapon
#   mount /mnt/boot/efi  # EF00
#   nixos-generate-config --root /mnt
#   systemctl start wpa_supplicant
#   wpa_cli  # add_network; set_network 0 {ssid "",psk "",key_mgmt WPA-PSK}; enable_network
#   nixos-install

# 2023-06-26 - first install
# help in configuration.nix(5) or in `nixos-help`

# temporary installs:
#   nix-env -iA nixos.firefox
#   nix-env -q
#   nix-env --uninstall firefox

# updates:
#   nix-channel --add <url>
#   nix-channel --update
#   nixos-rebuild switch --upgrade
#   nix-env -u '*'

{ lib, config, pkgs, ... }: {
  networking.hostName = "nixos-laptop";
  nix = {
    # settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    # systemd-boot.enable = true;
    grub = {
      enable = true;
      device = "nodev"; # if not EFI, use "/dev/sda"
      efiSupport = true;
      # useOSProber = true; # it works after second install
    };
    timeout = 2;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings =
    let extraLocale = "pl_PL.UTF-8";
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
  services.xserver = {
    # X11
    layout = "pl";
    enable = true;

    displayManager = {
      gdm.enable = true;
      defaultSession = "gnome-xorg"; # `xfce` vs `xfce+bspwm` vs `none+bspwm`
    };
    desktopManager.gnome.enable = true;
    # windowManager.bspwm.enable = true;
  };
  environment.gnome.excludePackages = (with pkgs; [
    # gnome-connections # rdp/vnc
    # gnome-console
    gnome-photos
    # gnome-text-editor
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    # gnome-calculator
    gnome-calendar
    # gnome-characters
    # gnome-contacts
    # gnome-disk-utility
    # gnome-font-viewer
    # gnome-logs
    # gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-weather
    # baobab # disk usage analyzer
    # cheese # webcam
    # eog # image viewer
    epiphany # web browser
    evince # document viewer
    # file-roller # archive manager
    geary # email reader
    # nautilus # file manager
    # seahorse # passwords and keys
    # simple-scan
    totem # video player
  ]);

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
    # try `nix-shell -p pavucontrol --run pavucontrol` -> Configuration -> Duplex if mic not working
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };
  services.logind = {
    lidSwitch = "ignore";
    extraConfig = ''
      RuntimeDirectorySize=2G
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nircek = {
    isNormalUser = true;
    description = "Marcin Zepp";
    extraGroups =
      [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" "libvirtd" ];
  };
  nixpkgs.config.allowUnfree = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # ------------------------------------- android studio and tools
    git
    gitRepo
    gnupg
    curl
    procps
    openssl
    gnumake
    nettools
    # For nixos < 19.03, use `androidenv.platformTools`
    androidenv.androidPkgs_9_0.platform-tools
    python311Packages.pyaxmlparser
    android-tools
    android-studio
    jdk
    openjdk8
    schedtool
    util-linux
    m4
    gperf
    perl
    libxml2
    zip
    unzip
    bison
    flex
    lzop
    python3
    # ------------------------------------- python
    python3Packages.python
    python3Packages.tkinter
    python3Packages.black
    taglib
    openssl
    git
    libxml2
    libxslt
    libzip
    zlib
    tk
    glib
    libGLU


    # ------------------------------------- rust
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
    cargo-generate
    wasm-pack
    wasm-bindgen-cli
    binaryen # wasm-opt; see https://github.com/NixOS/nixpkgs/issues/156890#issuecomment-1119221502
    pkg-config
    openssl

    # -------------------------------------
    python3
    git
    glances
    gnumake
    nixfmt
    imagemagick
    ffmpeg
    # gparted optionals:
    btrfs-progs
    exfatprogs
    jfsutils
    reiserfsprogs
    udftools
    # better to use options if possible
    firefox
    chromium
    obs-studio
    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.pl_PL
    gimp
    inkscape
    peek
    audacity
    vlc
    gparted
    transmission-gtk
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ritwickdey.liveserver

        ms-python.python
        ms-python.vscode-pylance
      ];
    })
    spotify-wrapped # use /nix/store/*-spotify-*/bin/spotify to log in
    virt-manager
    # ***
    safeeyes
    nixpkgs-fmt
  ];
  nixpkgs.overlays = [
    (final: prev: {
      spotify-adblock = prev.callPackage ./derivations/spotify-adblock.nix { };
      spotify-wrapped = prev.callPackage ./derivations/spotify-wrapped.nix {
        spotify-adblock = final.spotify-adblock;
      };
    })
  ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      # Add nix-shell indicator that makes clear when we're in nix-shell.
      # Set the prompt items to include it in addition to the defaults:
      # Described in: http://bewatermyfriend.org/p/2013/003/
      function nix_shell_prompt () {
        REPLY=''${IN_NIX_SHELL+"(nix-shell) "}
      }
      grml_theme_add_token nix-shell-indicator -f nix_shell_prompt '%F{magenta}' '%f'
      zstyle ':prompt:grml:left:setup' items rc nix-shell-indicator change-root user at host path vcs percent
      # see https://discourse.nixos.org/t/grml-zsh-config-auto-completion-issue-in-nixos/29937
      zstyle -d ':completion:*:sudo:*' command-path
      HISTSIZE=16777216  # programs.zsh.histSize would be overrided
      SAVEHIST=13421772800
      zstyle ':prompt:grml:left:items:user' pre '%F{cyan}%B'
      unsetopt extendedglob
      unsetopt histignoredups
      setopt nobeep
    '';
    promptInit = ""; # unset to use grml
    autosuggestions = { enable = true; };
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # defaultEditor = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  hardware.printers.ensurePrinters = [{
    name = "Brother_DCP-J132W";
    # see https://wiki.archlinux.org/title/CUPS/Printer-specific_problems#Network_printers
    deviceUri = "ipp://192.168.1.10/ipp/port1";
    model = "everywhere";
    # don't work; go to http://localhost:631/printers/Brother_DCP-J132W -> Maintenance/Modify Printer -> 2x Continue -> Generic/IPP Everywhere
  }];
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        DCP_J132W = {
          model = "DCP-J132W";
          ip = "192.168.1.10";
        };
      };
    };
  };

  services = {
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    openssh = {
      enable = true;
      openFirewall = true;
    };
  };
  # lenovo specific
  # consider adding <nixos-hardware/lenovo/ideapad>
  boot.initrd.kernelModules = [ "i915" ];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
  ];

  # microcode already in hardware-configuration.nix
  # config.hardware.enableRedistributableFirmware = true; -- already true, why?
  services.fstrim.enable = true; # ssd only

  # Gnome 40 introduced a new way of managing power, without tlp.
  # However, these 2 services clash when enabled simultaneously.
  # https://github.com/NixOS/nixos-hardware/issues/260
  services.tlp.enable = lib.mkDefault ((lib.versionOlder (lib.versions.majorMinor lib.version) "21.05")
    || !config.services.power-profiles-daemon.enable);
  boot.blacklistedKernelModules = lib.optionals (!config.hardware.enableRedistributableFirmware) [
    "ath3k"
  ];

  # networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.allowedUDPPorts = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
