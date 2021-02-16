import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Spacing



import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "kitty"

myBorderWidth   = 0

myModMask       = mod4Mask

myWorkspaces = [" dev ", " www ", " sys ", " file ", " vbox ", " chat ", " mus ", " vid ", " gfx "]

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [ ((modm .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart") -- Recompiles xmonad
  , ((modm, xK_r), spawn "xmonad --restart")   -- Restarts xmonad
  , ((modm, xK_q), io exitSuccess) 
  , ((modm, xK_Return), spawn myTerminal)
  , ((modm, xK_space), spawn "rofi -show combi")
  , ((modm, xK_w), kill)
  , ((modm, xK_t), withFocused $ windows . W.sink)
  , ((modm, xK_n ), sendMessage NextLayout)
  , ((modm, xK_Tab), windows W.focusDown)
  , ((modm, xK_k), windows W.focusDown)
  , ((modm, xK_j), windows W.focusUp)
  , ((modm .|. shiftMask, xK_j), windows W.swapUp)
  , ((modm .|. shiftMask, xK_k), windows W.swapDown)
  , ((modm, xK_e), spawn "pcmanfm")
  ]
  ++
  [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]
  

myLayout = mySpacing $ tiled ||| Mirror tiled ||| Full ||| mySpiral ||| Grid 
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100
    mySpiral  = spiral (130/130)

mySpacing = spacingRaw True             -- Only for >1 window
                       -- The bottom edge seems to look narrower than it is
                       (Border 0 15 10 10) -- Size of screen edge gaps
                       True             -- Enable screen edge gaps
                       (Border 5 5 5 5) -- Size of window gaps
                       True             -- Enable window gaps


myManageHook = composeAll
  [ className =? "Steam"  --> doFloat
  , className =? "firefox" --> doShift "web"
  , className =? "Pcmanfm" --> doShift "file"
  ]

myEventHook = mempty

myLogHook = return ()
--myLogHook = dynamicLogWithPP xmobarPP
--  [ ppOutput = hPutStrLn xmproc
--  , ppTitle = xmobarColor "green" "" . shorten 50
--  ]


myStartupHook = do
  spawnOnce "setxkbmap -layout it &"
  spawnOnce "numlockx &"
  spawnOnce "xset s 60 120"
  spawnOnce "xss-lock -n \"notify-send -u critical -t 5000 -- 'LOCKING in 1 min'\" -- slock &"
  spawnOnce "picom &"
  spawnOnce "wal -i ~/.wallpapers/ -o ~/.config/dunst/dunst-color.sh &"
  spawnOnce "./.config/polybar/launch.sh &"

main = xmonad defaults
  
defaults = def 
  { terminal           = myTerminal
  , borderWidth        = myBorderWidth
  , modMask            = myModMask
  , workspaces         = myWorkspaces
  , normalBorderColor  = myNormalBorderColor
  , focusedBorderColor = myFocusedBorderColor
  , keys               = myKeys
  , layoutHook         = myLayout
  , manageHook         = myManageHook
  , handleEventHook    = myEventHook
  , logHook            = myLogHook
  , startupHook        = myStartupHook
  }
  `additionalKeysP`
    [ ("<XF86MonBrightnessUp>", spawn "light -A 1")
    , ("<XF86MonBrightnessDown>", spawn "light -U 1")
    , ("<XF86AudioRaiseVolume>", spawn "sh -c \"pactl set-sink-mute 0 false ; pactl set-sink-volume 0 +1%\"")
    , ("<XF86AudioLowerVolume>", spawn "sh -c \"pactl set-sink-mute 0 false ; pactl set-sink-volume 0 -1%\"")
    , ("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle")
    , ("<XF86AudioMicMute>", spawn "pactl set-source-mute 1 toggle")
    , ("<XF86TouchpadToggle>", spawn "~/.config/toggle-touchpad.sh") --not work
    , ("<XF86Sleep>", spawn "dm-tool lock")
    , ("M-S-<Right>", windows W.swapDown)
    , ("M-S-<Left>", windows W.swapUp)    
    ]

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
