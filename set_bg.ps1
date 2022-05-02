$CUSTOM_STYL_NAME = "custom.styl"
$STYLE_STYL_NAME = "style.styl"

$PS1_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
$THEME_STYL_PATH = "$PS1_PATH/node_modules/hexo-theme-icarus/source/css"

$CUSTOM_STYL_CONTENT = @"
.is-2-column
    background-image url("../img/FF.png")
    background-position center center
    background-repeat no-repeat
    background-attachment fixed
    background-size cover
.footer
    background-color rgba(255, 255, 255, 0.8)
"@

$STYLE_STYL_CONTENT = @"

@import "custom"
"@

$CUSTOM_STYL_CONTENT | Out-File $THEME_STYL_PATH/$CUSTOM_STYL_NAME
$STYLE_STYL_CONTENT | Out-File -Append $THEME_STYL_PATH/$STYLE_STYL_NAME