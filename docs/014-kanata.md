# Kanata
 
For more information, see the official Kanata project: https://github.com/jtroo/kanata

hyprmcsr can start and stop Kanata as part of your session automation, but it does not manage Kanata automatically unless you add it to your profile commands.

Use Kanata for low-level Linux input remapping, keyboard layers, and shortcuts. The most common pattern is to launch Kanata in `onStart` and stop it in `onDestroy`.

## Recommended workflow

- Add Kanata startup commands to `onStart`.
- Add a matching shutdown command to `onDestroy`.
- Only set `requireSudo: true` if one of your startup or teardown commands actually needs root.
- Kanata itself usually does not require root on Linux.
- If you use Kanata with a custom config file, pass `--cfg /path/to/your/config.kbd`.

## Example profile integration

This example shows a real profile pattern from `example.default.profile.json`. It starts speedrun tools and Kanata-style remaps when session automation starts, and then stops the input remapping when the session ends.

```json
{
  "requireSudo": true,
  "onStart": [
    {
      "if": "[ \"$PROFILE\" = \"coop\" ]",
      "exec": "JAR_WORKDIR=\"$HOME/.config/NinjaLink\" $HYPRMCSR run-jar NinjaLink"
    },
    "$HYPRMCSR run-jar Ninjabrain-Bot",
    {
      "exec": "obs --startreplaybuffer",
      "if": "! pgrep -x obs >/dev/null"
    },
    "kanata --cfg ~/.config/kanata/kanata.kbd & echo $! > \"$STATE_DIR/kanata_mcsr.pid\""
  ],
  "onDestroy": [
    "kill $(cat \"$STATE_DIR/kanata_mcsr.pid\") >/dev/null 2>&1 || true"
  ]
}
```

## Notes about Kanata and hyprmcsr

- `hyprmcsr` does not automatically manage Kanata unless you explicitly start and stop it in your profile.
- `onStart` and `onDestroy` commands can be objects with `exec` and `if` for conditional execution.

## Common Kanata commands

- Start Kanata with a config file (no root needed):

```bash
kanata --cfg ~/.config/kanata/kanata.kbd
```

- List available devices / config information:

```bash
kanata --list
```

- Stop Kanata safely:

```bash
pkill -f '^kanata ' || true
```

## Troubleshooting

- If your remaps do not apply, make sure the Kanata process is actually running and that the config file path is correct.
- If Kanata is not stopped when the session ends: the `onStart` PID file path and the `onDestroy` path must match exactly. Always use `$STATE_DIR/kanata_mcsr.pid` instead of hardcoded paths like `/tmp/hyprmcsr/...`.
- If you use root access, make sure your user can run `sudo` without interactive issues during startup.

## Example Kanata keyboard configuration

As an example of how to configure a “QWERTZ” keyboard layout, consider the following ~/.config/kanata/kanata.kbd configuration. It defines `deflocalkeys-linux` for the German physical keys and a matching `defsrc`/`deflayer` setup for both default and MCSR modes.

To discover Linux input codes for custom keys, use `evtest` and press the physical key while monitoring the event output.

```lisp
(defcfg
  process-unmapped-keys yes
)

(deflocalkeys-linux
  ^    41
  ß    12
  ´    13
  ü    26
  +    27
  ö    39
  ä    40
  #    43
  <    86
  -    53
)

(defsrc
  esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  ^    1    2    3    4    5    6    7    8    9    0    ß    ´    bspc
  tab  q    w    e    r    t    z    u    i    o    p    ü    +    ret
  caps a    s    d    f    g    h    j    k    l    ö    ä    #
  lsft <    y    x    c    v    b    n    m    ,    .    -    rshft
  lctl lmet lalt           spc            ralt rmet menu rctl
  ins  home pgup del  end  pgdn
  up   left down rght
)

(deflayer default
  esc  f1   f2   f3   f4   f5   f6   f7   @tog_on f9 f10 f11  f12
  ^    1    2    3    4    5    6    7    8    9    0    ß    ´    bspc
  tab  q    w    e    r    t    z    u    i    o    p    ü    +    ret
  caps a    s    d    f    g    h    j    k    l    ö    ä    #
  lsft <    y    x    c    v    b    n    m    ,    .    -    rshft
  lctl lmet lalt           spc            ralt rmet menu rctl
  ins  home pgup del  end  pgdn
  up   left down rght
)

(deflayer mcsr
  esc  ret  ret  f3   ret  f5   f6   f7   @tog_off f9 f4 f11  f12
  ^    1    2    3    4    5    6    7    8    9    0    ß    ´    bspc
  tab  q    w    e    r    f16  z    u    i    o    p    ü    +    ret
  ret  f15  s    d    f    g    f18  f17  k    l    ö    ä    #
  lsft <    y    x    c    f3   @b_fork n m    ,    .    -    rshft
  lctl 0    lalt           spc            ralt rmet ret  rctl
  ins  home pgup del  end  pgdn
  up   f19  f14  f23
)

(defalias
  tog_on     (layer-switch mcsr)
  tog_off    (layer-switch default)
  b_fork     (fork b ret (lsft))
)
```
This is a concrete "QWERTZ" layout example you can use as a model for your own Kanata config.

The `@tog_on` / `@tog_off` aliases can be mapped to a key like `F8` if you want to toggle the MCSR layout on and off.
