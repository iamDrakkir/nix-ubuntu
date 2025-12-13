{ ... }:

{
  services.flatpak = {
    enable = true;
    packages = [
      "net.davidotek.pupgui2"
      "com.usebottles.bottles"
      "com.valvesoftware.Steam"
      "com.discordapp.Discord"
    ];
  };
}
