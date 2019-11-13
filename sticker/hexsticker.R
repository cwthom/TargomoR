# Script to create hexSticker

# hexSticker package
library(hexSticker)

# create sticker
sticker(subplot = "man/figures/targomo-logo.jpg",
        package = "TargomoR",
        p_size = 18,
        p_color = "#3f7f81",
        s_x = 1, s_y = 0.85,
        h_color = "#3f7f81",
        h_fill  = "#eaf7f7",
        url = "https://github.com/cwthom/TargomoR",
        u_size = 3,
        u_color = "#3f7f81",
        filename = "man/figures/logo.png")
