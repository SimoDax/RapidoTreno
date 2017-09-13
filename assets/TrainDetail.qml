import bb.cascades 1.4

Container {
    property string head_txt
    property string da_txt
    property string dur_txt
    property string a_txt
    horizontalAlignment: HorizontalAlignment.Fill
    bottomPadding: ui.du(1.0)
    background: bg.imagePaint

    attachedObjects: [
        ImagePaintDefinition {
            id: bg
            repeatPattern: RepeatPattern.X
            imageSource: "asset:///images/bg.png"
        }
    ]

    Header {
        id: head
        horizontalAlignment: HorizontalAlignment.Fill
        title: head_txt
        topMargin: ui.du(0)
    }
    Container {
        leftPadding: ui.du(2.2)
        horizontalAlignment: HorizontalAlignment.Fill
        topMargin: ui.du(0)
        topPadding: ui.du(0)

        Label {
            id: da
            text: da_txt
            textStyle.color: Color.Black
            textStyle.base: SystemDefaults.TextStyles.TitleText
            textStyle.fontWeight: FontWeight.W500
            bottomMargin: ui.du(0.0)
            topMargin: ui.du(0.0)
        }
        Label {
            id: dur
            text: dur_txt
            topMargin: ui.du(1.0)
            bottomMargin: ui.du(1.0)
            textStyle.fontSize: FontSize.Medium
            textStyle {
                base: SystemDefaults.TextStyles.BodyText
                color: Color.DarkGray
            }
        }
        Label {
            id: a
            text: a_txt
            textStyle.color: Color.Black
            textStyle.base: SystemDefaults.TextStyles.TitleText
            textStyle.fontWeight: FontWeight.W500
            topMargin: ui.du(0.0)
            bottomMargin: ui.du(0.0)
        }
    }
}
