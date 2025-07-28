```markdown
# Office-on-Wine Installer  
> **One-click, cracked Office 365 ProPlus / 2021 LTSC under Wine**  
> *Works on Arch, Ubuntu, Debian, Fedora, openSUSE, etc.*

---

## ⚡ TL;DR
```bash
git clone https://github.com/YOU/office-wine-installer.git
cd office-wine-installer
chmod +x office-wine-installer.fish
fish office-wine-installer.fish
```

Afterwards you can nuke every trace with  

```bash
rm -rf ~/.local/share/office-wine
```

---

📦 What is installed?

Component	Location (isolated)	Comment	
Wine 9.7	`~/.local/share/office-wine/wine`	Custom, isolated build	
Office 365 ProPlus	`~/.local/share/office-wine/365`	Cracked, full features	
Office 2021 LTSC	`~/.local/share/office-wine/ltsc`	Cracked, dark theme	
Desktop launchers	`~/.local/share/applications/*.desktop`	Only for your user	

---

🧼 Clean Removal

```bash
rm -rf ~/.local/share/office-wine
rm ~/.local/share/applications/*-{365,ltsc}.desktop
```

That’s it—no packages, no system files touched.

---

🐚 Interactive Menu
Running the script presents:

```
1) Office 365 ProPlus
2) Office 2021 LTSC
3) Install both
4) Re-install Wine runtime
5) Re-install system packages
6) Quit
```

---

🛠️ Dependencies

Distro	One-liner	
Arch / Manjaro	`yay -S wine-staging p7zip wget`	
Ubuntu / Debian	`sudo apt install wine64 wine32 p7zip-full wget`	
Fedora	`sudo dnf install wine p7zip wget`	
openSUSE	`sudo zypper in wine p7zip wget`	

The script auto-installs them if you choose option 5.

---

⚖️ Licence & Credits

- Office archives & Wine build © [Troplo](https://gist.github.com/Troplo/1a8701908f3801d450e6cf01ea6e9837)

  (original script: [gist link](https://gist.github.com/Troplo/1a8701908f3801d450e6cf01ea6e9837))  
- This wrapper & Fish port © 2024 SK-DEV-AI  
- Licence: MIT

---

⚠️ Legal Notice
The downloaded Office binaries are pre-activated cracks.

Use only if you accept the associated legal and security risks.

---

🤝 Contributing
Pull-requests welcome—keep it MIT!

```




# wine-office-suite
Cross-distro Wine wrapper for Microsoft Office suites (365 &amp; 2021 LTSC) – isolated, one-click install &amp; clean removal. 
