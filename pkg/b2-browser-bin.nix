{ self, lib, legacyPackages, ... }: let pname = "b2-browser"; pkg = "${pname}-bin"; in {
  packages = lib.mapAttrs (system: { target, hash }: {
    ${pkg} = let
      pkgs = legacyPackages.${system};
      version = "0.1.2";
      url = "https://github.com/BioniCosmos/${pname}/releases/download/v${version}/${pname}-${target}";
    in pkgs.runCommand
      "${pname}-${version}"
      {}
      "install -D ${pkgs.fetchurl { inherit url hash; }} $out/bin/${pname}";
  }) {
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-7Oaxlj88FN79yGVwZR6LysMO/nJ/DQObJgQnc0S2UNs=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-Q7fS3bRvD3med7jlppgn9nCkVHMxkzzEYrzAMSmJsCs=";
    };
    aarch64-darwin = {
      target = "macos-aarch64";
      hash = "sha256-vcns54omqzNHATR7akCctOhemaYz/3R1Cpu55T/ripo=";
    };
  };

  overlays.${pkg} = final: prev:
    { ${pkg} = self.packages.${prev.stdenv.hostPlatform.system}.${pkg}; };

  nixosModules.${pname} = { lib, config, pkgs, ... }: with lib; {
    options.services.${pname} = {
      enable = mkEnableOption pname;
      env = mkOption { type = types.anything; };
      package = mkPackageOption pkgs pkg {};
    };

    config = mkMerge [
      { nixpkgs.overlays = with self.overlays; [ b2-browser-bin b2-browser ]; }
      (let cfg = config.services.${pname}; in mkIf cfg.enable {
        systemd.services.${pname} = {
          serviceConfig = {
            Type = "exec";
            ExecStart = getExe' cfg.package pname;
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
