import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property var event
    property string type: event.hasOwnProperty("event") ? event.event : "comment"
    visible: title !== "" || type === "comment"
    property string author: type === "comment" ? event.user.login : event.actor.login
    property string date: event.created_at

    property bool last

    property string title: {
        if (type == "referenced") {
            return i18n.tr("<b>%1</b> referenced this issue from a commit %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "assigned") {
            return i18n.tr("Assigned to <b>%1</b> %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "closed") {
            return i18n.tr("<b>%1</b> closed this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "reopened") {
            return i18n.tr("<b>%1</b> reopened this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "merged") {
            return i18n.tr("<b>%1</b> merged this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "commit") {
            if (event.commits.length === 1)
                return i18n.tr("<b>%1</b> pushed 1 commit %2").arg(author).arg(friendsUtils.createTimeString(date))
            else
                return i18n.tr("<b>%1</b> pushed %3 commits %2").arg(author).arg(friendsUtils.createTimeString(date)).arg(event.commits.length)
        } else {
            return ""
        }
    }

    property string icon: {
        if (type == "referenced") {
            return "bookmark-o"
        } else if (type === "assigned") {
            return "user"
        } else if (type === "closed") {
            return "times"
        } else if (type === "reopened") {
            return "plus"
        } else if (type === "merged") {
            return "code-fork"
        } else if (type === "commit") {
            return "code"
        } else {
            return ""
        }
    }

    width: parent.width
    height: type === "comment" ? comment.height : eventItem.height + commitsColumn.anchors.topMargin + commitsColumn.height

    Rectangle {
        width: 1
        x: units.gu(1.5)
        y: -units.gu(1)
        height: units.gu(1) + (last || type === "comment" ? 0 : parent.height)
        z: -100
        //color: Qt.rgba(0.5,0.5,0.5,0.5)
        color: Qt.rgba(0.6,0.6,0.6,1)
    }

    CommentArea {
        id: comment
        event: root.event
        visible: type === "comment"
        width: parent.width
    }

    Row {
        id: eventItem
        width: parent.width
        visible: type !== "comment"
        spacing: units.gu(1)

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: height
            height: units.gu(3)
            radius: height/2
            color: type == "closed" ? colors["red"]
                                    : type === "reopened" ? colors["green"]
                                                          : type === "merged" ? colors["blue"]
                                                                              : Qt.rgba(0.6,0.6,0.6,1)
            antialiasing: true

            AwesomeIcon {
                name: icon
                anchors.centerIn: parent
            }
        }

        Label {
            id: titleLabel
            text: title
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Column {
        id: commitsColumn
        anchors.top: eventItem.bottom
        anchors.topMargin: units.gu(0.5)
        width: parent.width - x
        x: titleLabel.x

        Repeater {
            model: event.hasOwnProperty("commits") ? event.commits : []
            delegate: Item {
                id: commitItem
                width: parent.width
                height: msgLabel.height

                Label {
                    id: msgLabel
                    text: " • " + modelData.commit.message
                    font.family: "Monospaced"
                    width: 0.8 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                }

                Label {
                    id: shaLabel
                    text: modelData.sha.substring(0, 7)
                    font.family: "Monospaced"
                    width: 0.2 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: Theme.palette.normal.backgroundText
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
