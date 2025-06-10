# some-waywall-stuff
But I don't know if it is allowed like this... I will probably change this...

## Instructions
- `git clone https://github.com/Relacibo/some-waywall-stuff`

## Prism
- Use `<full path of this repo>/libglfw.so` for custom glfw in prism which is needed for waywall to work
- Use `<full path of this repo>/waywall wrap --` as your wrapper command in prism

For both see https://tesselslate.github.io/waywall/00_setup.html#instance-setup

## Config
### waywall
[init.lua](init.lua)

Belongs in the folder `~/config/waywall/`.

(I use the `razer-cli` to set my dpi. That might be different in your case. Ninjabrain bot does not really work so well yet though...)

I was inspired by this config file: https://github.com/sathya-pramodh/dotfiles/blob/main/waywall/init.lua

See https://tesselslate.github.io/waywall/01_basics.html

### scripts
[setup.sh](scripts/setup.sh)

You can also take inspiration from (or even use) my setup-script. Starts minecraft (with splitted sound), obs,
ninjabrain bot. You first have to download the jars manually from their repositories ([links](jars/README.md)) (You have to uncomment/modify some lines for it to work)
Use with `--coop` to also start `ninjalink`.

### Pipewire for splitting audio
[split-audio.conf](split-audio.conf)

Belongs in the folder `~/.config/pipewire/pipewire.conf.d/`.

Adjust Discord to use the `Discordsound` output.
In `scripts/setup.sh` prism gets started with `Minecraftsound` as default output which makes minecraft use that output. You have to uncomment the lines in `scripts/setup.sh` for that to work.
You can then split the audio in obs...

#### Run
```bash
<full path of this repo>/scripts/setup.sh [--coop]
```

## Waywall links
- docs: https://tesselslate.github.io/waywall/index.html
- source: https://github.com/tesselslate/waywall

## Licenses:
- [GWJGL](LWJGL-LICENSE.md) for libglfw.so
- [waywall](waywall-LICENSE) for waywall
- Everything else: [LICENSE](LICENSE)
