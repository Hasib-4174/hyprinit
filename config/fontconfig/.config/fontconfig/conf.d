<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Prefer Nerd Fonts for everything -->
  <match>
    <test name="family">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>JetBrainsMono Nerd Font</string>
    </edit>
  </match>

  <match>
    <test name="family">
      <string>sans-serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>JetBrainsMono Nerd Font</string>
    </edit>
  </match>

  <match>
    <test name="family">
      <string>serif</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>JetBrainsMono Nerd Font</string>
    </edit>
  </match>
</fontconfig>
