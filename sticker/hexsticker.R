# Script to create hexSticker

# hexSticker package
library(hexSticker)

# get google fonts (http://www.google.com/fonts)
library(showtext)
font_add_google("Caveat", "caveat")

# Automatically use showtext to render text for future devices
showtext_auto()

# create sticker
sticker(subplot = "man/figures/panel.png",
        package = "TargomoR",
        p_family = "caveat",
        p_size = 24,
        p_x = 1, p_y = 1.4,
        p_color = "#2e1a03",
        s_x = 1, s_y = 0.8,
        h_color = "#2e1a03",
        h_fill  = "#eaf7f7",
        url = "https://github.com/cwthom/TargomoR",
        u_size = 4,
        u_color = "#2e1a03",
        filename = "man/figures/sticker.png")

# set as logo
usethis::use_logo(img = "man/figures/sticker.png")
