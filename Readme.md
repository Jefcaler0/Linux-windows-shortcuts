# # Windows Shortcuts for Linux (Debian, Ubuntu, Fedora, Arch, OpenSUSE)

## 📌 Overview

This script automates the process of replicating Windows keyboard shortcuts on **Debian, Ubuntu, Fedora, Arch, OpenSUSE**, supporting **GNOME, KDE Plasma, XFCE, Cinnamon, and MATE**. Execute Mode test with DRY_RUN  and backup Before apply change on system.


## 🎯 Features

-   Detects the **Linux distribution** and **desktop environment** automatically.
-   Applies **Windows-like shortcuts** for file manager, terminal, settings, and more.
-   Supports **Debian-based, Fedora-based, Arch-based, and OpenSUSE-based distributions**.
-   Supports **GNOME, KDE Plasma, XFCE, Cinnamon, and MATE**.


## 🛠️ Supported Shortcuts
|Windows Shortcut|Linux Equivalent (GNOME/KDE/XFCE/Cinnamon/MATE) |Function     |
|----------------|-------------------------------|----------------------------- |
|`Win + E`|`Super + E` (Nautilus/Thunar/Nemo/Box)|Open File Manager             |
|`Win + D`|`Super + D`           |Show Desktop                                  |
|`Win + L `|`Super + L `           |Lock Screen                                 |
|`Win + Tab`|`Super + Tab`(GNOME)           |Open Activities Overview           |
|`Alt + Tab`|`Alt Tab`           |Switch Between Windows                        |
|`Win R`|`Alt + F2`(GNOME)/KRunner(KDE)            |Run Command                 |
|`Ctlr + Shift + Esc `|`Ctlr + Shift + Esc`           |Open System Monitor      |
|`Wint + I`|`Super + I`           |Open settings                                |
|`Win + X`|`Super + X`(Custom)           |Custom Menu (Future Implementations)  |

## 🚀 Installation & Usage
1.  Clone the repository:
    
    ```
    git clone https://github.com/Jefcaler0/Linux-windows-shortcuts
    cd windows-shortcuts-linux
    ```
    
2.  Make the script executable:
    
    ```
    chmod +x windows_shortcuts.sh
    ```
    
3.  Run the script:
    
    ```
    ./windows_shortcuts.sh
    ```
    
4. opcional Mode Test
    ```
     DRY_RUN=true ./windows_shortcuts.sh
    ```
    
The script will automatically detect your **distribution and desktop environment**, then apply the appropriate shortcuts.

## 🖥️ Supported Distributions

-   ✅ **Debian-based** (Debian, Ubuntu, Linux Mint, Pop!_OS, Zorin OS)
    
-   ✅ **Fedora-based** (Fedora, RHEL, AlmaLinux, Rocky Linux)
    
-   ✅ **Arch-based** (Arch Linux, Manjaro, EndeavourOS)
    
-   ✅ **OpenSUSE-based** (Leap, Tumbleweed)
    

### Supported Desktop Environments

-   ✅ GNOME (Default in Debian, Ubuntu, Fedora)
    
-   ✅ KDE Plasma (Default in OpenSUSE, KDE Neon)
    
-   ✅ XFCE (Default in Xubuntu, Manjaro XFCE)
    
-   ✅ Cinnamon (Default in Linux Mint)
    
-   ✅ MATE (Default in Ubuntu MATE)
    

### 🔹 How It Works

1.  **The script detects your Linux distribution** using `lsb_release -is` or falls back to `Unknown`.
    
2.  **It then identifies the desktop environment** using `XDG_CURRENT_DESKTOP`.
    
3.  **Based on the detected environment**, it applies the relevant Windows-like shortcuts:
    
    -   **GNOME** → Uses `gsettings`
        
    -   **KDE Plasma** → Uses `kwriteconfig5` and `qdbus`
        
    -   **XFCE** → Uses `xfconf-query`
        
    -   **Cinnamon** → Uses `gsettings`
        
    -   **MATE** → Uses `gsettings`
        
4.  Finally, it prints the **distribution and desktop environment detected** and confirms that shortcuts have been applied.
    
If you use a different **desktop environment** or **distribution**, let us know, and we'll add support!

----------

## 🔧 Contributing

Feel free to fork this repository, improve the script, and submit a **pull request**!

----------

## 📜 License

This project is licensed under the **MIT License**.