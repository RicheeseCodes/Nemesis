# Nemesis

A fork of [Rayfield](https://github.com/SiriusSoftwareLtd/Rayfield), a UI library for Roblox executors.

![license](https://img.shields.io/badge/license-Apache_2.0-black)
![status](https://img.shields.io/badge/status-fork_baseline-black)
![upstream](https://img.shields.io/badge/upstream-Rayfield-black)

## Status

This is the baseline fork. The library here is Rayfield's source verbatim, with a fork attribution header. No behavior changes yet. Modifications will land on top of this commit.

Built with permission from Jenson (Rayfield maintainer).

## Install

```lua
local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/siriusxcontact/Nemesis/main/Nemesis.lua"))()
```

While `siriusxcontact` is suspended, use the mirror:

```lua
local Nemesis = loadstring(game:HttpGet("https://raw.githubusercontent.com/RicheeseCodes/Nemesis/main/Nemesis.lua"))()
```

## API

Identical to Rayfield. Reference: [docs.sirius.menu/rayfield](https://docs.sirius.menu/rayfield).

A starter script is at [examples/example.lua](examples/example.lua) (the Rayfield example, unchanged).

## License

Apache 2.0. See [LICENSE](LICENSE). Original Rayfield credits are preserved in the `Nemesis.lua` header and in the source file's notice block. Modifications to the source are noted in commit history.

## Upstream

- Repository: https://github.com/SiriusSoftwareLtd/Rayfield
- Documentation: https://docs.sirius.menu/rayfield
- Author: Sirius Software (Jenson and team)
