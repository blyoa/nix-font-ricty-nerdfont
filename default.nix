{
  lib,
  stdenvNoCC,
  nerd-font-patcher,
  python312Packages,
  ricty,

  adjustXAvgCharWidth ? true,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ricty-nerdfont";
  version = "1.0.0";

  nativeBuildInputs =
    [
      nerd-font-patcher
    ]
    ++ lib.optionals adjustXAvgCharWidth [
      python312Packages.fonttools
    ];

  dontUnpack = true;

  buildPhase =
    ''
      runHook preBuild

      cp ${ricty}/share/fonts/truetype/ricty/Ricty-*.ttf .

      for f in Ricty-*.ttf; do
        nerd-font-patcher -c "$f" -out dist/
      done;
    ''
    # Adjust xAvgCharWidth to solve the problem
    # where characters are displayed too wide in Windows.
    + lib.optionals adjustXAvgCharWidth ''
      pushd dist/

      ttx -t 'OS/2' Ricty*.ttf
      for f in Ricty*.ttx; do
        sed -i 's/^\(\s\+<xAvgCharWidth\s\+value="\)[0-9]\+\(".*\)$/\1500\2/g' "$f"
        mv "''${f%.ttx}.ttf" "''${f%.ttx}-orig.ttf"
        ttx -m "''${f%.ttx}-orig.ttf" "$f" -o "''${f%.ttx}.ttf" 
      done
      rm *-orig.ttf

      popd
    ''
    + ''
      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    install -m644 -D --target $out/share/fonts/truetype/ricty-nerdfont dist/*.ttf

    runHook postInstall
  '';
}
