import bb.cascades 1.4

Container {

    property alias text: tit.text

    id: titolo
    //minHeight: ui.du(10.0)
    //maxHeight: ui.du(10.0)
    minHeight: ui.ddu(10.86)
    maxHeight: ui.ddu(10.86)
    background: redgrad.imagePaint
    horizontalAlignment: HorizontalAlignment.Fill
    attachedObjects: [
        ImagePaintDefinition {
            id: redgrad
            repeatPattern: RepeatPattern.X
            imageSource: "asset:///images/redgrad.png"
        }
    ]
    Container {
        topPadding: ui.du(2.0)
        leftPadding: ui.du(2.2)
        rightPadding: ui.du(2.2)
        bottomPadding: ui.du(2.2)
        Label {
            id: tit    //it's not what you think..
            textStyle.color: Color.White
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.fontSize: FontSize.Large
            textStyle.fontWeight: FontWeight.W500
            textStyle.fontSizeValue: 0.0
            textStyle.textAlign: TextAlign.Default
            textFit.mode: LabelTextFitMode.Default
        }
    }
}