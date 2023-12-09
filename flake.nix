{
  description = "IPL replacement modchip for the Nintendo GameCube";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    systems.flake = false;
  };

  outputs = { ... } @ inputs: inputs.flake-parts.lib.mkFlake {
    inherit inputs;
  } ({ config, flake-parts-lib, getSystem, inputs, lib, options, ... }:
    let
      rootConfig = config;
      rootOptions = options;
    in
    {
      _file = ./flake.nix;
      imports = [ ];
      config.perSystem = { config, inputs', nixpkgs, options, pkgs, system, ... }:
        let
          systemConfig = config;
          systemOptions = options;
        in
        {
          _file = ./flake.nix;
          config.devShells.default = pkgs.callPackage
            ({ mkShell
            , cmake
            , gcc-arm-embedded
            , python3
            , pico-sdk
            }: mkShell {
              name = "picoboot";
              nativeBuildInputs = [
                cmake
                gcc-arm-embedded
                python3
              ];

              env = {
                PICO_SDK_PATH="${pico-sdk}/lib/pico-sdk";
              };
            })
            { };
        };
      config.systems = import inputs.systems;
  });
}
