{ nixpkgs ? import <nixpkgs> { } }:

with nixpkgs;

let  mkEnv = { stdenv, python27, pythonPackages, openssl }:
  stdenv.mkDerivation {
    name = "mantl-env";
    buildInputs = [ python27 pythonPackages.pyyaml openssl terraform packer ansible2 openssh ];
  };
in callPackage mkEnv {}
