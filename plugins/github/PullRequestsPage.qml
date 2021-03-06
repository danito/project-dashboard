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
import "../../components"
import "../../ubuntu-ui-extras"
import "../../ubuntu-ui-extras/listutils.js" as List

PluginPage {
    id: page
    title: i18n.tr("Pull Requests")

    property string sort: doc.get("sort", "number")

    property var allIssues: issues.children.sort(function(a, b) { return parseInt(b) - parseInt(a) })//sortAllIssues()

    function sortAllIssues() {
        return issues.concat(closedIssues).sort(function sort(a1, a2) {
            print("sorting", page.sort)
            if (page.sort === "number") {
                return a2.number - a1.number
            } else if (page.sort === "assignee") {
                return a2.assignee.login - a1.assignee.login
            } else if (page.sort === "milestone") {
                return a2.milestone.number - a1.milestone.number
            }
        })
    }

    actions: [
        Action {
            id: newIssueAction
            iconSource: getIcon("add")
            text: i18n.tr("New Pull")
            onTriggered: PopupUtils.open(Qt.resolvedUrl("NewPullRequestPage.qml"), plugin, {repo: repo, branches: plugin.branches, action: reload})
        },

        Action {
            id: filterAction
            text: i18n.tr("Filter")
            iconSource: getIcon("filter")
            onTriggered: PopupUtils.open(filterPopover, value)
            visible: !wideAspect
        },

        Action {
            id: viewAction
            text: i18n.tr("View")
            iconSource: getIcon("navigation-menu")
            onTriggered: PopupUtils.open(viewMenu, value)
        }
    ]

    flickable: sidebar.expanded ? null : listView

    onFlickableChanged: {
        if (flickable === null) {
            listView.topMargin = 0
            listView.contentY = 0
        } else {
            listView.topMargin = units.gu(9.5)
            listView.contentY = -units.gu(9.5)
        }
    }

    ListView {
        id: listView
        anchors {
            right: parent.right
            left: sidebar.right
            top: parent.top
            bottom: parent.bottom
        }
        model: allIssues
        delegate: IssueListItem {
            number: modelData
            show: selectedFilter(modelData)
        }
        clip: true
    }

    Label {
        anchors.centerIn: listView
        text: settings.get("showClosedTickets", false) ? i18n.tr("No pull requests") : i18n.tr("No open pull requests")
        visible: List.filteredCount(allIssues, selectedFilter) === 0
        fontSize: "large"
        opacity: 0.5
    }

    property var selectedFilter: allFilter

    property var allFilter: function(number) {
        var issue = issues.childrenData[String(number)].info
        return issue.state === "open" || settings.get("showClosedTickets", false)
    }

    property var createdFilter: function(number) {
        var issue = issues.childrenData[String(number)].info
        return issue.user && issue.user.login === github.user && (issue.state === "open" || settings.get("showClosedTickets", false))
    }

    Scrollbar {
        flickableItem: listView
    }

    Sidebar {
        id: sidebar
        width: units.gu(25)
        expanded: wideAspect
        Column {
            width: parent.width

            ListItem.Header {
                text: i18n.tr("Filter")
            }

            ListItem.SingleValue {
                text: i18n.tr("All Requests")
                selected: allFilter === selectedFilter
                onClicked: selectedFilter = allFilter
                value: List.filteredCount(allIssues, allFilter)
            }

            ListItem.SingleValue {
                text: i18n.tr("Yours")
                selected: createdFilter === selectedFilter
                onClicked: selectedFilter = createdFilter
                value: List.filteredCount(allIssues, createdFilter)
            }

//            ListItem.SingleValue {
//                text: i18n.tr("Mentioning you")
//                value: "1"
//            }
        }
    }

    Component {
        id: viewMenu

        Popover {
            height: childrenRect.height
            Column {
                width: parent.width

                ListItem.Standard {
                    text: i18n.tr("Show closed pull requests")
                    control: CheckBox {
                        checked: settings.get("showClosedTickets", false)
                        onClicked: checked = settings.sync("showClosedTickets", checked)
                    }
                }
            }
        }
    }

    Component {
        id: filterPopover

        Popover {
            contentHeight: column.height
            Column {
                id: column
                width: parent.width

                ListItem.Header {
                    text: i18n.tr("Filter")
                }

                ListItem.SingleValue {
                    text: i18n.tr("All Requests")
                    selected: allFilter === selectedFilter
                    onClicked: selectedFilter = allFilter
                    value: List.filteredCount(allIssues, allFilter)
                }

                ListItem.SingleValue {
                    text: i18n.tr("Yours")
                    selected: createdFilter === selectedFilter
                    onClicked: selectedFilter = createdFilter
                    value: List.filteredCount(allIssues, createdFilter)
                }

    //            ListItem.SingleValue {
    //                text: i18n.tr("Mentioning you")
    //                value: "1"
    //            }
            }
        }
    }
}
