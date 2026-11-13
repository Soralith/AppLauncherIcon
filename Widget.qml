import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: root
    required property var host

    readonly property int size: host.settings.iconSize
    implicitWidth: size
    implicitHeight: size

    function launchAll() {
        const lines = String(host.settings.apps).split("\n")
        for (let i = 0; i < lines.length; i++) {
            const cmd = lines[i].trim()
            if (cmd.length > 0)
                Quickshell.execDetached(["sh", "-c", cmd])
        }
    }

    function openSettings() {
        Quickshell.execDetached(["qs", "-c", "sekaipop", "ipc", "call", "plugins", "settings", host.id])
    }

    // Copies a dropped image into the plugin folder, then points iconImage at the copy.
    function importImage(url) {
        const src = decodeURIComponent(String(url).replace(/^file:\/\//, ""))
        const m = src.match(/\.(png|jpe?g|svg|webp|gif)$/i)
        if (!m) return false
        const dest = host.path("icon-" + Date.now() + "." + m[1].toLowerCase())
        Quickshell.execDetached(["sh", "-c",
            "cp -- \"$1\" \"$2\" && qs -c sekaipop ipc call plugins set \"$3\" iconImage \"$2\"",
            "sh", src, dest, host.id])
        return true
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: host.settings.roundOutline ? host.settings.cornerRadius : 0
        color: !host.settings.showBackground ? "transparent"
             : (area.containsMouse ? host.theme.pSurfaceHover : host.theme.pSurface)
        border.width: host.settings.outlineWidth
        border.color: host.theme.pLine
        scale: area.pressed ? 0.94 : 1
        Behavior on scale { NumberAnimation { duration: 80 } }

        // The picture. When "Round the image" is on, it is clipped by a mask
        // shaped like the picture's painted area, so non-square images round correctly.
        Item {
            id: imageBox
            anchors.centerIn: parent
            width: parent.width * host.settings.imageFill / 100
            height: width
            visible: host.settings.iconImage !== ""

            Image {
                id: img
                anchors.fill: parent
                source: host.settings.iconImage !== "" ? "file://" + host.settings.iconImage : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                layer.enabled: host.settings.roundImage
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: maskItem
                }
            }

            Item {
                id: maskItem
                anchors.fill: parent
                visible: false
                layer.enabled: host.settings.roundImage
                Rectangle {
                    anchors.centerIn: parent
                    width: img.paintedWidth
                    height: img.paintedHeight
                    radius: Math.min(host.settings.cornerRadius, Math.min(width, height) / 2)
                    color: "black"
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: host.settings.iconImage === ""
            text: host.settings.iconName
            color: host.theme.pInk
            font.family: host.theme.iconFont
            font.pixelSize: root.size * 0.55
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (host.editing) return          // in Edit Desktop a click just selects
            if (mouse.button === Qt.RightButton) root.openSettings()
            else root.launchAll()
        }
    }

    DropArea {
        anchors.fill: parent
        onEntered: (drag) => { drag.accepted = drag.hasUrls }
        onDropped: (drop) => {
            if (drop.hasUrls) {
                for (const u of drop.urls) {
                    if (root.importImage(u.toString())) break
                }
            }
            drop.accept()
        }
    }
}
