-- Laptop Screen (2.5K 16:10, 1.5x scale, 120Hz)
hl.monitor({
    output   = "eDP-2",
    mode     = "2560x1600@120.01",
    position = "0x0",
    scale    = 1.67,
})

-- Samsung External Monitor (24" 1080p, 100Hz, placed to the right)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100.00",
    position = "auto-left",
    scale    = 1.25,
})

-- Prevent blurry text/windows in XWayland apps when using fractional scaling
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Vietnamese Input Method (Fcitx5)
-- Note: Do NOT set GTK_IM_MODULE on Wayland; GTK uses Wayland text-input protocol natively
hl.env("XMODIFIERS", "@im=fcitx")

-- Autostart Fcitx5
hl.exec_cmd("fcitx5 -d --replace")

-- Lock screen: lock and turn off display immediately (DPMS off)
hl.bind("SUPER + L", function()
    hl.dispatch(hl.dsp.global("caelestia:lock"))
    hl.exec_cmd("sleep 0.2 && hyprctl dispatch dpms off")
end)

-- Only wake screen on keypress, ignore mouse movements while sleeping
hl.config({
    misc = {
        mouse_move_enables_dpms = false,
        key_press_enables_dpms  = true,
    },
    input = {
            -- Mouse: tắt acceleration, đường thẳng tuyến tính
        sensitivity        = 0.5,      -- 0 = không thay đổi DPI, range: -1.0 đến 1.0
        accel_profile      = "flat", -- flat = tắt hoàn toàn acceleration
    }


})

