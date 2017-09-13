import bb.cascades 1.4

Container {
    property string nome_txt
    property string arrProg_txt
    property string arrEff_txt
    property string partProg_txt
    property string partEff_txt
    property string bin_txt
    property string or_txt

    background: bg.imagePaint

    attachedObjects: [
        ImagePaintDefinition {
            id: bg
            repeatPattern: RepeatPattern.X
            imageSource: "asset:///images/bg.png"
        }
    ]
    layout: StackLayout {
        orientation: LayoutOrientation.TopToBottom
    }
    leftPadding: ui.du(1.5)
    rightPadding: ui.du(0)
    bottomPadding: ui.du(1.0)
    Label {
        text: nome_txt
        textStyle.fontSize: FontSize.Medium
        textStyle.fontWeight: FontWeight.W500
        textStyle.color: Color.Black
    }
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight

        }
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.5
            }
            leftPadding: ui.du(0.6)
            Label {
                text: "Arrivo progr. " + arrProg_txt + "\nArrivo eff. " + arrEff_txt
                multiline: true
                textStyle.color: Color.Black
            }
        }
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.6
            }
            Label {
                text: "Partenza progr. " + partProg_txt + "\nPartenza eff. " + partEff_txt
                multiline: true
                textStyle.color: Color.Black

            }
        }
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 0.9
            }
            Label {
                text: "Bin. progr. " + bin_txt + "\nBin. reale: " + or_txt
                multiline: true
                textStyle.color: Color.Black
            }
        }
    }
}