#!/usr/bin/env bash
# =============================================================
# install.sh — Tự động khôi phục toàn bộ môi trường làm việc
# Hệ điều hành: Arch Linux
# Tác giả: nk
# =============================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo -e "${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     Dotfiles Installer — by nk       ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

# Kiểm tra Arch Linux
if ! command -v pacman &>/dev/null; then
    error "Script này chỉ chạy trên Arch Linux (yêu cầu pacman)."
fi

# ─────────────────────────────────────────
# BƯỚC 1: Cập nhật hệ thống
# ─────────────────────────────────────────
info "Bước 1/6 — Cập nhật hệ thống..."
sudo pacman -Syu --noconfirm
success "Hệ thống đã cập nhật."

# ─────────────────────────────────────────
# BƯỚC 2: Cài đặt GNU Stow (bắt buộc)
# ─────────────────────────────────────────
info "Bước 2/6 — Cài đặt GNU Stow..."
sudo pacman -S --needed --noconfirm stow
success "GNU Stow đã được cài đặt."

# ─────────────────────────────────────────
# BƯỚC 3: Cài đặt package chính thức
# ─────────────────────────────────────────
info "Bước 3/6 — Cài đặt ${BOLD}$(wc -l < "$DOTFILES_DIR/pkglist.txt")${NC} package chính thức..."
sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt" || \
    warn "Một số package có thể không còn tồn tại trong repo, tiếp tục..."
success "Package chính thức đã cài đặt xong."

# ─────────────────────────────────────────
# BƯỚC 4: Cài đặt paru (AUR Helper)
# ─────────────────────────────────────────
info "Bước 4/6 — Kiểm tra AUR helper (paru)..."
if ! command -v paru &>/dev/null; then
    info "Đang cài đặt paru từ AUR..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-install
    (cd /tmp/paru-install && makepkg -si --noconfirm)
    rm -rf /tmp/paru-install
    success "paru đã được cài đặt."
else
    success "paru đã có sẵn, bỏ qua."
fi

info "Cài đặt ${BOLD}$(wc -l < "$DOTFILES_DIR/aur_list.txt")${NC} package AUR..."
paru -S --needed --noconfirm - < "$DOTFILES_DIR/aur_list.txt" || \
    warn "Một số AUR package có thể lỗi, kiểm tra thủ công sau."
success "Package AUR đã cài đặt xong."

# ─────────────────────────────────────────
# BƯỚC 5: Kích hoạt service hệ thống
# ─────────────────────────────────────────
info "Bước 5/6 — Kích hoạt các service hệ thống..."
sudo systemctl enable --now docker.service 2>/dev/null && \
    success "Docker service đã kích hoạt." || \
    warn "Docker chưa được cài đặt, bỏ qua."

# ─────────────────────────────────────────
# BƯỚC 6: Stow — Tạo symlink cấu hình
# ─────────────────────────────────────────
info "Bước 6/6 — Tạo symlink cấu hình bằng GNU Stow..."
cd "$DOTFILES_DIR"

for dir in */; do
    pkg="${dir%/}"
    # Bỏ qua thư mục .git và các file không phải package
    [[ "$pkg" == ".git" ]] && continue
    [[ ! -d "$pkg" ]] && continue

    # Nếu file gốc đã tồn tại, backup trước
    if [ -d "$HOME/.config/${pkg}" ] && [ ! -L "$HOME/.config/${pkg}" ]; then
        warn "Backup ~/.config/$pkg -> ~/.config/$pkg.bak"
        mv "$HOME/.config/$pkg" "$HOME/.config/${pkg}.bak"
    fi

    stow -R "$pkg" && success "  Linked: $pkg" || warn "  Lỗi khi link: $pkg"
done

echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   🎉 Hoàn tất! Môi trường đã phục   ║"
echo "  ║   hồi. Vui lòng đăng xuất & đăng    ║"
echo "  ║   nhập lại để áp dụng toàn bộ.      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
