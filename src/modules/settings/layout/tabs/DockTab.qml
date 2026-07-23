pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.components
import qs.service
import qs.modules.settings
import qs.modules.settings.layout.components
import qs.config

Flickable {
    id: root

    clip: true
    contentHeight: col.implicitHeight

    Column {
        id: col

        spacing: SettingsConfig.tabColumnSpacing
        width: root.width

        SettingsGroup {
            title: "Behavior"
            width: col.width

            RowLayout {
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    color: ColorConfig.text
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.fontSettingsBody
                    opacity: SettingsConfig.labelOpacity
                    text: "Autohide"
                }
                Toggle {
                    active: SettingsService.adapter.dock.autohideEnabled

                    onToggled: {
                        SettingsService.adapter.dock.autohideEnabled = !active;
                        SettingsService.save();
                    }
                }
            }
        }
        SettingsGroup {
            contentSpacing: SettingsConfig.groupContentSpacingSm
            flat: true
            title: "Geometry"
            width: col.width

            Rectangle {
                id: marginTile

                function currentText() {
                    return Math.round(SettingsService.adapter.dock.marginBottom).toString();
                }

                border.color: ColorConfig.textAlpha07
                border.width: SettingsConfig.hairlineBorderWidth
                color: ColorConfig.textAlpha04
                height: SettingsConfig.numericTileHeight
                radius: SettingsConfig.tileRadius
                width: parent.width

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: SettingsConfig.tileContentMargin
                    anchors.rightMargin: SettingsConfig.tileContentMargin
                    spacing: SettingsConfig.tileContentSpacing

                    Text {
                        Layout.fillWidth: true
                        color: ColorConfig.text
                        font.family: FontConfig.fontFamily
                        font.pixelSize: FontConfig.fontSettingsBody
                        font.weight: Font.DemiBold
                        opacity: SettingsConfig.labelOpacity
                        text: "Bottom Margin"
                    }
                    Rectangle {
                        border.color: marginInput.activeFocus ? ColorConfig.accent : ColorConfig.textAlpha15
                        border.width: SettingsConfig.hairlineBorderWidth
                        color: ColorConfig.textAlpha07
                        implicitHeight: SettingsConfig.numberFieldHeight
                        implicitWidth: SettingsConfig.numberFieldWidth
                        radius: SettingsConfig.fieldRadius

                        Behavior on border.color {
                            ColorAnimation {
                                duration: GlobalConfig.animationFast
                            }
                        }

                        TextInput {
                            id: marginInput

                            anchors.fill: parent
                            anchors.margins: SettingsConfig.textFieldInset
                            color: ColorConfig.text
                            font.family: FontConfig.fontFamily
                            font.pixelSize: FontConfig.fontSettingsBody
                            horizontalAlignment: TextInput.AlignHCenter
                            selectByMouse: true
                            text: marginTile.currentText()

                            onEditingFinished: {
                                var v = parseInt(text, 10);
                                if (!isNaN(v)) {
                                    v = Math.max(0, Math.min(80, v));
                                    SettingsService.adapter.dock.marginBottom = v;
                                    SettingsService.save();
                                }
                                marginInput.text = Qt.binding(marginTile.currentText);
                            }
                        }
                    }
                    Text {
                        color: ColorConfig.text
                        font.family: IconConfig.fontFamily
                        font.pixelSize: FontConfig.fontSettingsWindowIcon
                        opacity: resetMa.containsMouse ? SettingsConfig.iconHoverOpacity : SettingsConfig.faintOpacity
                        text: IconConfig.refresh

                        Behavior on opacity {
                            NumberAnimation {
                                duration: GlobalConfig.animationFast
                            }
                        }

                        MouseArea {
                            id: resetMa

                            anchors.fill: parent
                            anchors.margins: SettingsConfig.iconHoverHitSlop
                            hoverEnabled: true

                            onClicked: {
                                SettingsService.adapter.dock.marginBottom = 10;
                                marginInput.text = Qt.binding(marginTile.currentText);
                                SettingsService.save();
                            }
                        }
                    }
                }
            }
        }
        Item {
            height: SettingsConfig.tabBottomSpacerHeight
        }
    }
}
