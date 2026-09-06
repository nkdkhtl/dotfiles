#!/usr/bin/env bash
# =============================================================
# sync.sh — Cập nhật dotfiles sau khi cài thêm phần mềm mới
# Dùng khi: thêm ứng dụng mới, thay đổi config, chuẩn bị push lên git
# =============================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }

echo -e "${BLUE}[sync] Đồng bộ danh sách package...${NC}"

# Cập nhật danh sách package chính thức
pacman -Qqen > "$DOTFILES_DIR/pkglist.txt"
success "pkglist.txt: $(wc -l < "$DOTFILES_DIR/pkglist.txt") packages"

# Cập nhật danh sách AUR
pacman -Qqem > "$DOTFILES_DIR/aur_list.txt"
success "aur_list.txt: $(wc -l < "$DOTFILES_DIR/aur_list.txt") packages"

# Refresh tất cả symlink Stow
echo -e "${BLUE}[sync] Làm mới symlink Stow...${NC}"
cd "$DOTFILES_DIR"
for dir in */; do
    pkg="${dir%/}"
    [[ "$pkg" == ".git" ]] && continue
    [[ ! -d "$pkg" ]] && continue
    stow -R "$pkg" 2>/dev/null && success "  Refreshed: $pkg" || warn "  Bỏ qua: $pkg"
done

# Hiển thị thay đổi trong git
echo ""
info "Thay đổi chưa được commit:"
git -C "$DOTFILES_DIR" status --short

echo ""
echo -e "${GREEN}[✓] Sync hoàn tất! Dùng 'git add . && git commit -m \"update\"' để lưu thay đổi.${NC}"
