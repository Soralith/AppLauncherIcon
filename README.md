# App Launcher Icon

A [SekaiPop](https://github.com/Blapples/SekaiPop/) desktop widget plugin. It puts a resizable icon on your desktop, click it and every app you configured starts. Drop an image onto it to change the picture, and style the frame, outline and corners from Settings.

## Requirements

- SekaiPop with plugin API `1`.
- Qt 6.5 or newer (the rounded image uses `QtQuick.Effects`).

## Installation

1. Put the plugin folder in `~/.config/sekaipop/plugins/` (or `$XDG_CONFIG_HOME/sekaipop/plugins/`). **The folder name must be exactly `app-launcher-icon`**, because the folder name is the plugin's id.

   ```
   ~/.config/sekaipop/plugins/app-launcher-icon/
     plugin.json
     Widget.qml
   ```

2. Reload the plugins or restart the shell:

   ```sh
   qs -c sekaipop ipc call plugins reload
   ```

3. Right-click the desktop, choose **Edit Desktop**, and click the plugin's tile on the shelf.

If the widget does not appear, run `qs -c sekaipop ipc call plugins list`. It reports why a folder was skipped (a missing file, a manifest typo, and so on).

## Usage

| Action | Result |
| --- | --- |
| Left click | Starts every command in **Apps to open** |
| Right click | Opens this plugin's settings |
| Drop an image on the icon | Copies it into the plugin folder and uses it as the icon |
| Click in Edit Desktop | Only selects the widget; nothing is launched |

If right click is intercepted by the desktop's own menu on your setup, open the settings with the shell's command instead:

```sh
qs -c sekaipop ipc call plugins settings app-launcher-icon
```

Settings are also available at **Settings > Desktop > Plugins**, or through the **Settings** key beside a selected widget in Edit Desktop.

## Settings

### Apps

| Setting | Default | Description |
| --- | --- | --- |
| Apps to open (`apps`) | `firefox` and `kitty`, one per line | One command per line. Each runs through `sh -c`, so arguments and things like `flatpak run ...` work. Blank lines are ignored. |

### Look

| Setting | Default | Description |
| --- | --- | --- |
| Icon name (`iconName`) | `rocket_launch` | A [Material Symbols](https://fonts.google.com/icons) name. Used only when no image is set. |
| Icon image (`iconImage`) | empty | Full path to an image. Set automatically when you drop one. Clear it to go back to the icon name. |
| Icon size (`iconSize`) | `96` | 32 to 256 px. |
| Show background (`showBackground`) | on | The filled card behind the image. Turn off to show only the image. |
| Outline width (`outlineWidth`) | `3` | 0 to 8 px. `0` removes the outline. |
| Outline color (`outlineColorMode`) | Theme | Theme, White, Black, Mint, Cyan or Custom. |
| Custom color (`outlineCustomColor`) | `#ffffff` | A hex code such as `#ff7a8c` (3 or 6 digits, `#` optional). Used only when Outline color is Custom. An invalid value falls back to the theme color. |
| Round the outline (`roundOutline`) | on | On: rounded corners. Off: square corners. |
| Round the image (`roundImage`) | off | On: the picture itself is clipped to rounded corners. Off: it stays rectangular. |
| Corner radius (`cornerRadius`) | `16` | 0 to 64 px. Shared by the outline and the image when they are rounded. |
| Image fill (`imageFill`) | `60` | 30 to 100 %. How much of the icon the image covers. |

### Recipes

- **Just the image, no frame:** Show background off, Outline width `0`, Image fill `100`.
- **Rounded image, no frame:** the above, plus Round the image on.
- **Fully square icon:** Round the outline off, Round the image off.
- **Colored frame:** leave the background on and pick an Outline color.

## Where things are stored

- **Dropped images:** `~/.config/sekaipop/plugins/app-launcher-icon/icon-<timestamp>.<ext>`. Each drop adds a new file, delete old ones by hand if you like.
- **Settings and position:** `~/.local/state/sekaipop/plugins/app-launcher-icon.json`. This survives deleting or reinstalling the plugin folder, so your configuration comes back.

If you keep the plugin in a git repository, add this to `.gitignore` so dropped images do not show up as untracked files:

```
icon-*
```

## Updating and removing

- **Update:** replace `plugin.json` and `Widget.qml`, then reload. Saved settings are kept; new settings start at their defaults.
- **Remove:** delete the plugin folder. Delete the state file above too if you want the settings gone.

## Further reading

The SekaiPop plugin documentation covers the manifest fields, the `host` object and the plugin API: `docs/PLUGINS.md`, `docs/PLUGIN-SETTINGS.md` and `docs/PLUGIN-INSTALL.md` in the [SekaiPop repository](https://github.com/Blapples/SekaiPop/).
