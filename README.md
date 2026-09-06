# 🏡 nk's Dotfiles

Cấu hình cá nhân cho hệ thống **Arch Linux + Hyprland + Caelestia** của tôi.
Quản lý symlink bằng **GNU Stow** — không copy file, không lo mất đồng bộ.

## 📦 Nội dung

| Package | Ứng dụng |
| :--- | :--- |
| `caelestia/` | Caelestia Shell (keybinds, lockscreen, theme, assets Dark Souls) |
| `hypr/` | Hyprland (monitors, keybinds, variables) |
| `fcitx5/` | Bộ gõ tiếng Việt Fcitx5 + Bamboo |
| `fish/` | Fish Shell config |
| `foot/` | Foot Terminal |
| `fastfetch/` | System info (neofetch thay thế) |
| `btop/` | System monitor |
| `starship/` | Shell prompt (starship.toml) |
| `fuzzel/` | App launcher |
| `lazydocker/` | Docker TUI manager |

## 🆕 Cài đặt trên máy mới (Arch Linux)

Mở terminal và chạy 3 lệnh:

```bash
# 1. Clone repo về máy
git clone https://github.com/nkdkhtl/dotfiles.git ~/Projects/dotfiles

# 2. Vào thư mục và cấp quyền thực thi
cd ~/Projects/dotfiles && chmod +x install.sh

# 3. Chạy script cài đặt tự động
./install.sh
```

Script sẽ tự động:
- Cài đặt toàn bộ phần mềm từ `pkglist.txt` và `aur_list.txt`
- Cài đặt `paru` (AUR helper) nếu chưa có
- Kích hoạt các service hệ thống (Docker...)
- Tạo symlink toàn bộ cấu hình vào `$HOME`

## 🔄 Đồng bộ sau khi thay đổi

Mỗi khi cài thêm ứng dụng mới hoặc chỉnh sửa config, chạy:

```bash
cd ~/Projects/dotfiles
./sync.sh
```

Sau đó commit và push:
```bash
git add .
git commit -m "feat: add <tên ứng dụng>"
git push
```

## 🏗️ Cấu trúc thư mục

```text
dotfiles/
├── install.sh          # Script cài đặt tự động trên máy mới
├── sync.sh             # Script đồng bộ sau khi thay đổi
├── pkglist.txt         # Danh sách package chính thức (pacman)
├── aur_list.txt        # Danh sách package AUR
├── .gitignore
│
├── caelestia/.config/caelestia/
├── hypr/.config/hypr/
├── fcitx5/.config/fcitx5/
├── fish/.config/fish/
├── foot/.config/foot/
├── fastfetch/.config/fastfetch/
├── btop/.config/btop/
├── starship/.config/starship.toml
├── fuzzel/.config/fuzzel/
└── lazydocker/.config/lazydocker/
```

## ⚙️ Thêm cấu hình mới vào dotfiles

1. Tạo thư mục package theo chuẩn Stow:
   ```bash
   mkdir -p ~/Projects/dotfiles/<tên-app>/.config/
   cp -r ~/.config/<tên-app> ~/Projects/dotfiles/<tên-app>/.config/
   ```
2. Xóa thư mục gốc (để Stow tạo symlink thay thế):
   ```bash
   rm -rf ~/.config/<tên-app>
   ```
3. Chạy Stow để tạo symlink:
   ```bash
   cd ~/Projects/dotfiles && stow <tên-app>
   ```
