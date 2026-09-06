local vars = require("variables")

hl.config({
    input = {
        kb_layout          = "us",
        numlock_by_default = false,
        repeat_delay       = 250,
        repeat_rate        = 35,
        focus_on_close     = 1,

        -- Mouse: tắt acceleration, đường thẳng tuyến tính
        sensitivity        = 0,      -- 0 = không thay đổi DPI, range: -1.0 đến 1.0
        accel_profile      = "flat", -- flat = tắt hoàn toàn acceleration

        touchpad           = {
            natural_scroll       = true,
            disable_while_typing = vars.touchpadDisableTyping,
            scroll_factor        = vars.touchpadScrollFactor,
        },
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },
})
