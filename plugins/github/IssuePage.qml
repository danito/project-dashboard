/*
 * Project Dashboard - Manage everything about your projects in one app
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: page
    
    title: i18n.tr("Issue %1").arg(issue.number)

    property var issue

    actions: [
        Action {
            id: editAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
        },

        Action {
            id: closeAction
            text: i18n.tr("Close")
            iconSource: getIcon("close")
        }
    ]

    Flickable {
        anchors.fill: parent
        anchors.margins: units.gu(2)

        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width
            spacing: units.gu(1)
            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: issue.title
                fontSize: "large"
            }

            Row {
                spacing: units.gu(1)
                UbuntuShape {
                    height: stateLabel.height + units.gu(1)
                    width: stateLabel.width + units.gu(2)
                    color: issue.state === "open" ? "green" : "red"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: issue.state === "open" ? i18n.tr("Open") : i18n.tr("Closed")
                    }
                }

                Label {
                    text: i18n.tr("<b>%1</b> opened this issue %2").arg(issue.user.login).arg(friendsUtils.createTimeString(issue.created_at))
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextArea {
                id: textArea
                width: parent.width
                text: issue.hasOwnProperty("body") ? renderMarkdown(issue.body) : ""
                height: __internal.linesHeight(Math.min(15, Math.max(4, edit.lineCount)))
                placeholderText: i18n.tr("No description set.")
                readOnly: true
                textFormat: Text.RichText
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                // FIXME: Hack necessary to get the correct line height
                Label {
                    id: edit
                    visible: false
                    width: parent.width
                    //textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: issue.hasOwnProperty("body") ? issue.body : ""//textArea.text
                    font: textArea.font
                }
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton { action: editAction }
        ToolbarButton { action: closeAction }
    }
}