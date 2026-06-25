pragma ComponentBehavior: Bound

import QtQuick

import qs.lib.layout
import qs.lib.service
import qs.modules.bar
import qs.modules.bar.layout.components
import qs.modules.bar.service
import qs.styles

WidgetPanel {
    id: root

    readonly property var _cells: {
        var first = displayMonth;
        var startOffset = first.getDay();
        var gridStart = new Date(first.getFullYear(), first.getMonth(), 1 - startOffset);
        var arr = [];
        for (var i = 0; i < 42; i++) {
            var d = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
            arr.push(d);
        }
        return arr;
    }
    readonly property var _months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var _today: DateTimeService.date
    readonly property var _weekdays: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    property var displayMonth: {
        var n = DateTimeService.date;
        return new Date(n.getFullYear(), n.getMonth(), 1);
    }

    function _sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }
    function _shiftMonth(delta) {
        displayMonth = new Date(displayMonth.getFullYear(), displayMonth.getMonth() + delta, 1);
    }

    clip: true
    implicitHeight: col.implicitHeight + BarConfig.panelPadding * 2
    implicitWidth: 280

    MouseArea {
        anchors.fill: parent
    }
    Column {
        id: col

        anchors.margins: BarConfig.panelPadding
        spacing: 0

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        Item {
            height: 32
            width: parent.width

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: ColorConfig.text
                font.bold: true
                font.family: FontConfig.fontFamily
                font.pixelSize: BarConfig.fontSize + 1
                text: root._months[root.displayMonth.getMonth()] + " " + root.displayMonth.getFullYear()
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                    color: prevMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                    height: 20
                    radius: 10
                    width: 20

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.text
                        font.family: IconConfig.fontFamily
                        font.pixelSize: FontConfig.fontPanelActionIcon
                        text: IconConfig.chevronLeft
                    }
                    MouseArea {
                        id: prevMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: root._shiftMonth(-1)
                    }
                }
                Rectangle {
                    color: todayMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                    height: 20
                    radius: 10
                    width: 20

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.text
                        font.pixelSize: FontConfig.fontPanelActionIcon
                        text: "•"
                    }
                    MouseArea {
                        id: todayMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: root.displayMonth = new Date(root._today.getFullYear(), root._today.getMonth(), 1)
                    }
                }
                Rectangle {
                    color: nextMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                    height: 20
                    radius: 10
                    width: 20

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.text
                        font.family: IconConfig.fontFamily
                        font.pixelSize: FontConfig.fontPanelActionIcon
                        text: IconConfig.chevronRight
                    }
                    MouseArea {
                        id: nextMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: root._shiftMonth(1)
                    }
                }
                Rectangle {
                    color: closeMa.containsMouse ? BarConfig.capsuleBgHover : BarConfig.capsuleBg
                    height: 20
                    radius: 10
                    width: 20

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.text
                        font.family: IconConfig.fontFamily
                        font.pixelSize: FontConfig.fontPanelActionIcon
                        text: IconConfig.close
                    }
                    MouseArea {
                        id: closeMa

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: PanelService.closePanel()
                    }
                }
            }
        }
        Divider {
            width: parent.width
        }
        Item {
            height: 8
            width: parent.width
        }
        Row {
            readonly property real cellW: width / 7

            width: parent.width

            Repeater {
                model: root._weekdays

                delegate: Item {
                    required property string modelData

                    height: 22
                    width: parent.cellW

                    Text {
                        anchors.centerIn: parent
                        color: ColorConfig.textDim
                        font.bold: true
                        font.family: FontConfig.fontFamily
                        font.pixelSize: BarConfig.fontSize - 1
                        text: parent.modelData
                    }
                }
            }
        }
        Item {
            height: 2
            width: parent.width
        }
        Grid {
            readonly property real cellW: width / 7

            columns: 7
            width: parent.width

            Repeater {
                model: root._cells

                delegate: Item {
                    id: cell

                    readonly property bool inMonth: modelData.getMonth() === root.displayMonth.getMonth()
                    readonly property bool isToday: root._sameDay(modelData, root._today)
                    required property var modelData

                    height: parent.cellW
                    width: parent.cellW

                    Rectangle {
                        anchors.centerIn: parent
                        color: cell.isToday ? ColorConfig.accent : "transparent"
                        height: width
                        radius: width / 2
                        width: Math.min(parent.width, parent.height) - 4

                        Text {
                            anchors.centerIn: parent
                            color: cell.isToday ? "white" : (cell.inMonth ? ColorConfig.text : ColorConfig.textDim)
                            font.bold: cell.isToday
                            font.family: FontConfig.fontFamily
                            font.pixelSize: BarConfig.fontSize
                            opacity: cell.inMonth || cell.isToday ? 1.0 : 0.4
                            text: cell.modelData.getDate()
                        }
                    }
                }
            }
        }
        Item {
            height: 4
            width: parent.width
        }
    }
}
