// SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
// SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls
import QtFeedback 5.0

import org.kde.kirigami 2.2 as Kirigami

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal clicked(string text)
    signal held(string text)

    property string text
    property string sub
    property string display
    property string subdisplay
    property bool voicemail: false
    property bool special: false

    Rectangle {
        anchors.fill: parent
        z: -1
        color: Kirigami.Theme.highlightColor
        radius: Kirigami.Units.smallSpacing
        opacity: mouse.pressed ? 0.4 : 0
    }

    // vibration
    HapticsEffect {
        id: vibrate
        attackIntensity: 0.0
        attackTime: 0
        fadeTime: 0
        fadeIntensity: 0.0
        intensity: 0.5
        duration: Kirigami.Units.shortDuration
    }

    Controls.AbstractButton {
        id: mouse
        anchors.fill: parent

        onPressed: vibrate.start()
        onClicked: root.clicked(parent.text)

        onPressAndHold: root.held(parent.text)
    }

    ColumnLayout {
        spacing: -5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Controls.Label {
            id: main

            font.pixelSize: applicationWindow().smallMode ? Kirigami.Units.gridUnit * 1.2 : Kirigami.Units.gridUnit * 1.75
            text: root.display || root.text
            opacity: special ? 0.4 : 1.0
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Controls.Label {
            id: longHold

            text: root.subdisplay || root.sub
            opacity: 0.4
            Layout.minimumWidth: parent.width
            horizontalAlignment: Text.AlignHCenter

            Kirigami.Icon {
                source: "call-voicemail"
                visible: root.voicemail
                width: Kirigami.Units.iconSizes.small
                height: width
                color: Kirigami.Theme.textColor
            }
        }
    }
}
