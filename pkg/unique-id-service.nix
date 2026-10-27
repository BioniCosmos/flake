{ self, lib, legacyPackages, ... }: let pname = "unique-id-service"; in {
  packages = lib.mapAttrs (system: { target, hash }: {
    ${pname} = let
      pkgs = legacyPackages.${system};
      version = "0.1.2";
      url = "https://github.com/BioniCosmos/${pname}/releases/download/v${version}/uid-${target}";
    in pkgs.runCommand
      "${pname}-${version}"
      { meta.mainProgram = "uid"; }
      "install -D ${pkgs.fetchurl { inherit url hash; }} $out/bin/uid";
  }) {
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-XWge+CpNP5pjlfHt64HNlafEScF0VKfjUe2flIzJRyw=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-7Y0wqe6RvoQUMjBgc2cwCg6J0cJkyYvO5p9KC51q5z4=";
    };
    aarch64-darwin = {
      target = "macos-aarch64";
      hash = "sha256-WnGaZbxHeLfXyryM1SD7oytZzAs16xeUnU07Va5wJ8M=";
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
            StateDirectory = "%N";
            PrivateDevices = true;
            PrivateIPC = true;
            # `PrivatePIDs`, `DynamicUser`, `StateDirectory` cannot be set simultaneously.
            # issue: <https://github.com/systemd/systemd/issues/41014>
            # PrivatePIDs = true;
            PrivateUsers = true;
            ProtectHostname = true;
            ProtectClock = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
            RestrictNamespaces = true;
            PrivateBPF = true;
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
