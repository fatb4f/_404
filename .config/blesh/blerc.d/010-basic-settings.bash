# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Basic settings


## The following setting specifies the input encoding. Currently only "UTF-8"
## and "C" is available.

#bleopt input_encoding=UTF-8


## The following setting specifies the pager used by ble.sh.  This is used to
## show the help of commands (f1).

#bleopt pager=less

## The following setting specifies the editor used by ble.sh.  This is used for
## the widget edit-and-execute (C-x C-e) and editor for a large amount of
## command line texts.  Possible values include, for example, "vim", "emacs
## -nw" and "nano".

bleopt editor=nvim


## The following settings sets the behavior of visible bells (vbell).  The
## option "vbell_duration" sets the time duration to show the vbell.  The
## option "vbell_align" controls the position of vbell with a colon-separated
## fields. The fields "left", "center", and "right" specify that the vbell
## should be shown up on the left, center, and right, respectively, in the
## terminal display.  The default is "right".  The field "panel" specify that
## vbell should be shown below the command line within the line editor
## interface (as far as the line editor is currently active).  The faces
## "vbell", "vbell_erase", and "vbell_flash" specify the graphic style of the
## vbell, the one after vbell is erased, and the one used to blink the vbell,
## respectively.

#bleopt vbell_default_message=' Wuff, -- Wuff!! '
#bleopt vbell_duration=2000
#bleopt vbell_align=right
#ble-face vbell='reverse'
#ble-face vbell_erase='bg=252'
#ble-face vbell_flash='fg=green,reverse'


