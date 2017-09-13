import bb.cascades 1.4

Container {

    layout: StackLayout {
        orientation: LayoutOrientation.TopToBottom

    }
    horizontalAlignment: HorizontalAlignment.Fill

    leftPadding: ui.du(1.7)
    bottomPadding: ui.du(1)
    topPadding: ui.du(1)
    rightPadding: ui.du(2.2)
    property alias acquistato: acq.text
    property alias desc: desc.text
    property alias data: data.text
    property alias type: type.text
    property string color
    property variant id

    Container {

        Label {
            id: desc
            textStyle.fontWeight: FontWeight.Bold
            textStyle.color: Color.create(color)
            textStyle.fontSize: FontSize.Medium
        }
    }

    Container {
        layout: DockLayout {

        }

        verticalAlignment: VerticalAlignment.Bottom
        horizontalAlignment: HorizontalAlignment.Fill
        
        Container {
            id: dati
            horizontalAlignment: HorizontalAlignment.Left
            topPadding: ui.du(1)
            leftPadding: ui.du(1)
            
            Label {
                id: data
                textStyle.color: Color.create(color)
                bottomMargin: ui.du(0.0)
            }
            Label {
                id: acq
                textStyle.color: Color.create(color)
                bottomMargin: ui.du(0.0)
                topMargin: ui.du(0.0)
            }
            Label {
                id: type
                textStyle.color: Color.create(color)
                topMargin: ui.du(2)
            }
        }

        Container {
            horizontalAlignment: HorizontalAlignment.Right

            verticalAlignment: VerticalAlignment.Center
            ImageButton {
                id: pdf
                defaultImageSource: "asset:///images/pdf.png"
                maxHeight: ui.du(11)
                maxWidth: ui.du(11)
                onClicked: {
                    itemRoot.ListItem.view.openpdf(ListItemData.idsales, ListItemData.tsid)
                }
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
            }

        }
    }
}
