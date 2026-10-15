{ self, lib, legacyPackages, ... }: let pname = "b2-browser"; pkg = "${pname}-bin"; in {
  packages = lib.mapAttrs (system: { target, hash }: {
    ${pkg} = derivation (let
      pkgs = legacyPackages.${system};
      version = "0.1.1";
      url = "https://github.com/BioniCosmos/${pname}/releases/download/v${version}/${pname}-${target}";
    in {
      name = "${pname}-${version}";
      inherit system;
      builder = "/bin/sh";
      PATH = "${pkgs.coreutils}/bin";
      args = [
        "-c"
        ''
        mkdir -p $out/bin
        cp ${pkgs.fetchurl { inherit url hash; executable = true; }} $out/bin/${pname}
        ''
      ];
    });
  }) {
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-UkmrQg9rtpmZzkw2jFVS7s/8SnSLwWvjqL93LbNanyA=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-WS2ai+MILEAU4EtRoHM2QfTLeT4gR1V35HSY2sDwbOQ=";
    };
    aarch64-darwin = {
      target = "macos-aarch64";
      hash = "sha256-4RlNc8eJ5+7T/wM+5Zs2dTFP1LOonj7M3ma4juxp5fo=";
    };
  };

  overlays.${pkg} = final: prev:
    { ${pkg} = self.packages.${prev.stdenv.hostPlatform.system}.${pkg}; };

  nixosModules.${pname} = { config, lib, pkgs, ... }: {
    options.services.${pname} = {
      enable = lib.mkEnableOption pname;
      env = lib.mkOption { type = lib.types.anything; };
    };

    config = { nixpkgs.overlays = [ self.overlays.${pkg} ]; }
      // lib.mkIf config.services.${pname}.enable {
        systemd.services.${pname} = {
          serviceConfig = {
            Type = "exec";
            ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.${pkg}}/bin/${pname}";
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
          environment = config.services.${pname}.env;
          startLimitIntervalSec = 15 * 60;
          startLimitBurst = 6;
          wantedBy = [ "multi-user.target" ];
        };
      };
  };
}
