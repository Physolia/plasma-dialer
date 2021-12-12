// SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
// SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2021 Alexey Andreyev <aa13q@ya.ru>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0

import org.kde.kirigami 2.19 as Kirigami

import org.kde.telephony 1.0
import "Call"

Kirigami.ApplicationWindow {
    wideScreen: false
    id: appWindow
    pageStack.globalToolBar.canContainHandles: true
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    // needs to work with 360x720 (+ panel heights)
    minimumWidth: 300
    minimumHeight: minimumWidth + 1
    width: Kirigami.Settings.isMobile ? 400 : 650
    height: Kirigami.Settings.isMobile ? 650 : 500

    title: i18n("Phone")

    readonly property bool smallMode: appWindow.height < Kirigami.Units.gridUnit * 20

    Kirigami.PagePool { id: pagePool }

    function getPage(name) {
        switch (name) {
        case "History": return pagePool.loadPage("qrc:/HistoryPage.qml");
        case "Contacts": return pagePool.loadPage("qrc:/ContactsPage.qml");
        case "Dialer": return pagePool.loadPage("qrc:/DialerPage.qml");
        case "Call": return pagePool.loadPage("qrc:/Call/CallPage.qml");
        }
    }

    property bool isWidescreen: appWindow.width >= appWindow.height
    onIsWidescreenChanged: changeNav(!isWidescreen);

    function switchToPage(page, depth) {
        while (pageStack.depth > depth) pageStack.pop()
        pageStack.push(page)
        page.forceActiveFocus()
    }

    function changeNav(toNarrow) {
        if (toNarrow) {
            sidebarLoader.active = false;
            globalDrawer = null;

            let bottomToolbar = Qt.createComponent("qrc:/BottomToolbar.qml")
            footer = bottomToolbar.createObject(appWindow);
        } else {
            if (footer != null) {
                footer.destroy();
                footer = null;
            }
            sidebarLoader.active = true;
            globalDrawer = sidebarLoader.item;
        }
    }

    function selectModem() {
        const deviceUniList = DeviceUtils.deviceUniList()
        if (deviceUniList.length === 0) {
            console.warn("Modem devices not found")
            return ""
        }

        if (deviceUniList.length === 1) {
            return deviceUniList[0]
        }
        console.log("TODO: select device uni")
    }

    function call(number) {
        getPage("Dialer").pad.number = number
        switchToPage(getPage("Dialer"), 0)
    }

    Component.onCompleted: {
        // initial page and nav type
        switchToPage(getPage("Dialer"), 1);
        changeNav(!isWidescreen);
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
        handle.anchors.bottomMargin: appWindow.footer ? (appWindow.footer.height + Kirigami.Units.largeSpacing) : 0
    }

    Loader {
        id: sidebarLoader
        source: "qrc:/Sidebar.qml"
        active: false
    }

    USSDSheet {
        id: ussdSheet
        onResponseReady: {
            // TODO: debug
            // USSDUtils.respond(response)
        }
    }

    ImeiSheet {
        id: imeiSheet
        function show() {
            imeiSheet.imeis = DeviceUtils.equipmentIdentifiers()
            imeiSheet.open()
        }
    }

    Connections {
        target: CallUtils

        function onMissedCallsActionTriggered() {
            root.visible = true;
        }

        function onCallStateChanged(state) {
            if (CallUtils.callState === DialerTypes.CallState.Active) {
                getPage("Dialer").pad.number = ""
            }
            // TODO: also activate on Dialing state
        }
    }

    Connections {
        target: UssdUtils

        function onNotificationReceived(deviceUni, message) {
            ussdSheet.showNotification(message)
        }

        function onRequestReceived(deviceUni, message) {
            ussdSheet.showNotification(message, true)
        }

        function onInitiated(deviceUni, command) {
            ussdSheet.open()
        }
    }
}