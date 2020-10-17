# LumUI

My _World of Warcraft_ UI addons.

Full Interface: [LumUI](http://www.wowinterface.com/downloads/info18616-lumUI.html) | GitHub: [LumUI](https://github.com/greven/LumUI)

![LumUI](https://i.imgur.com/VVahwzm.jpg)

All _fonts_ or _assets_ included are **not** to be distributed.

## About

LumUI is a UI Compilation created having in mind utility within an attractive look focused on information. The main element of the UI is my oUF layout, [oUF_lumen](https://www.wowinterface.com/downloads/info16885-oUFLumen.html) | [github](https://github.com/greven/oUF_Lumen). The UI is fully featured yet keeping it simple and easy to install without needing to configure lots of addons.
My goal is to reduce the amount of configuration needed, the juggling of addons and profiles. There are no profiles for LumUI, it is what it is, yet it is extensible by editing some provided settings, (edit and keep your `config.lua` to override defaults and keep your settings separate from updates).

## Installation

1. Backup your `Fonts` folder (if you have it), `Interface` and `WTF` folder.
2. Unzip the archive into the World of Warcraft \_retail\_ folder. Not the Addons folder, the World of Warcraft **\_retail\_** Folder. This is because inside the archive you will find a Fonts folder and an Interface folder.
3. That's it, there is no WTF because it's not needed by any addon needing configuration (at least important ones).
4. Refer to any individual addons if you need help configuring them. Most of the addons in this pack are configured through Lua editing so they might not be fitted for some users.
5. This UI works out of the package. You might only need to move some elements of the frames around.

## Addons

Keeping addons to a minimum from now on. You can supplement the UI with other addons of your choice.

- LumUI **Unit Frames**
- oUF_Lumen
- Butsu
- tullaRange

## Features

- Minimalist design
- Standalone (oUF and several oUF plugins embedded - Experience, Reputation, Smooth...)
- Layout works for all type of roles (damage, healing or tanking)
- Feature complete (All frames supported, including Boss and Arena)
- Complete support for class specific power (Combo Points, Chi, Holy Power, Insanity, etc...)
- All frames supported, including Party, Raid (TBA), Boss and Arena frames
- Movable frames using **/lmf**

## Instructions

- If you need to override any default options please do so on `config.lua`. Go to **LumUI** and **oUF_Lumen** default config files (`defaults.lua`) to see the available options and override your settings on the `config.lua` file (save this file between updates, both for LumUI and OUF_Lumen).
- In config.lua (LumUI and oUF_Lumen) there is an example to use a more [compact centered layout](https://i.imgur.com/b7PG5va.jpg), uncomment the comments files to achieve that layout. Since version 9 LumUI uses a more wide layout with the Action Bars following the layout used by Blizzard default action bars. If you uncomment those files, please **disable**, **reload** and **re-enable** LumUI so the layout resets.

## Roadmap

For future tasks, check the project [tasks file](https://github.com/greven/LumUI/blob/master/tasks.todo) and [oUF_Lumen tasks file](https://github.com/greven/oUF_Lumen/blob/master/tasks.todo).

## Feedback

If you have any question regarding the layout please leave a comment in the [comment section of WoWInterface](https://www.wowinterface.com/downloads/info18616-LumUI.html#comments).
For bug reports and feature request please use [Github Issues](https://github.com/greven/LumUI/issues).
