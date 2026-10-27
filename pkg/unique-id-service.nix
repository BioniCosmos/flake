{ self, lib, legacyPackages, ... }: let pname = "unique-id-service"; in {
  packages = lib.mapAttrs (system: { target, hash }: {
    ${pname} = let
      pkgs = legacyPackages.${system};
      version = "0.1.1";
      url = "https://github.com/BioniCosmos/${pname}/releases/download/v${version}/uid-${target}";
    in pkgs.runCommand
      "${pname}-${version}"
      { meta.mainProgram = "uid"; }
      "install -D ${pkgs.fetchurl { inherit url hash; }} $out/bin/uid";
  }) {
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-sjXDtBUcLUOs4ou8JYS43vhlZeKSz3WqRGd1s+XhGHI=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-OB2QN5/QhxTCTzdPiTGiwEUHAQ7gesbtes16lb29vlI=";
    };
    aarch64-darwin = {
      target = "macos-aarch64";
      hash = "sha256-uhPoIjZIgjqbV1LIO2QV7J5HTm79QbSATFXorlM3Drs=";
    };
  };

  overlays.${pname} = final: prev:
    { ${pname} = self.packages.${prev.stdenv.hostPlatform.system}.${pname}; };

  nixosModules.${pname} = { lib, config, pkgs, ... }: with lib; {
    options.services.${pname} = {
      enable = mkEnableOption pname;
      env = mkOption { type = types.anything; };
    };

    config = mkMerge [
      { nixpkgs.overlays = [ self.overlays.${pname} ]; }
      (let cfg = config.services.${pname}; in mkIf cfg.enable {
        systemd.services.${pname} = {
          serviceConfig = {
            Type = "exec";
            ExecStart = getExe pkgs.${pname};
            RestartSec = 1;
            RestartSteps = 5;
            RestartMaxDelaySec = 60;
            Restart = "on-failure";
            ProtectProc = "invisible";
            ProcSubset = "pid";
            DynamicUser = true;
            CapabilityBoundingSet = "";
            UMask = 0077;
            ProtectHome = true;
            PrivateDevices = true;
            PrivateIPC = true;
            PrivatePIDs = true;
            PrivateUsers = true;
            ProtectHostname = true;
            ProtectClock = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
            RestrictNamespaces = true;
            # There seems to be a bug in systemd where `PrivateBPF` and
            # `PrivatePIDs` cannot be enabled simultaneously.
            # PrivateBPF = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            RestrictRealtime = true;
            SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
            SystemCallErrorNumber = "EPERM";
            SystemCallArchitectures = "native";
          };
          environment = cfg.env;
          startLimitIntervalSec = 15 * 60;
          startLimitBurst = 6;
          wantedBy = [ "multi-user.target" ];
        };
      })
    ];
  };
}
