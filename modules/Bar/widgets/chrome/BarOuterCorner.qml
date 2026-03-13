import QtQuick
import QtQuick.Shapes

import "../../../Theme/theme.js" as Theme

Item {
  id: root

  property bool rightSide: false
  property color fillColor: "transparent"
  property real curveWidth: width
  property real curveHeight: height
  property real controlFactor: Theme.barOuterCornerControlFactor

  width: 28
  height: 18

  Shape {
    anchors.fill: parent
    asynchronous: true
    antialiasing: true
    preferredRendererType: Shape.CurveRenderer
    transform: Scale {
      origin.x: root.width / 2
      origin.y: root.height / 2
      xScale: root.rightSide ? -1 : 1
    }

    ShapePath {
      fillColor: root.fillColor
      strokeWidth: 0
      startX: 0
      startY: 0

      PathLine {
        x: root.curveWidth
        y: 0
      }

      PathCubic {
        x: 0
        y: root.curveHeight
        control1X: root.curveWidth * root.controlFactor
        control1Y: 0
        control2X: 0
        control2Y: root.curveHeight * root.controlFactor
      }

      PathLine {
        x: 0
        y: 0
      }
    }
  }
}
