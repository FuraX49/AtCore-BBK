import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4

Action {
    id: component
    property string program: "/bin/systemctl"
    property variant parameters : [""]
}
