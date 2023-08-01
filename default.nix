let
  pkgs = import <nixpkgs> { };
  blog =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/blog/archive/cc28c6e08b50786d17f1558c36a0408b44ed7e8d.tar.gz");
  letscape =
    import
      (builtins.fetchTarball
        "https://github.com/willmcpherson2/letscape/archive/b512df5c13132362ba5fa4444b9c869dbce94964.tar.gz")
      { };
in
pkgs.dockerTools.buildImage {
  name = "willmcpherson2.com";
  tag = "latest";
  copyToRoot = pkgs.buildEnv {
    name = "root";
    paths = [
      pkgs.nodejs-18_x
      pkgs.bashInteractive
      pkgs.coreutils
      letscape
    ];
  };
  config = {
    WorkingDir = "/letscape";
    Env = [
      "LETSCAPE_DB=/letscape/db.json"
    ];
    Cmd = [ "npm" "run" "start" ];
  };
}
