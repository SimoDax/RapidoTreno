import bb.cascades 1.4

Container {
    id: main
    
    property alias codice: nome.text
    property alias dest: dest.text
    property alias orario: orario.text
    property alias binario: binario.text
    property alias ritardo: ritardo.text
    property alias image: image.imageSource
    property alias bg: main.background
    property string color
    
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        leftPadding: ui.du(1.5)
        rightPadding: ui.du(0)
        bottomPadding: ui.du(1.5)

    
        Container{
            layoutProperties: StackLayoutProperties {
                spaceQuota: 2.5

            }
        verticalAlignment: VerticalAlignment.Center
        Label {
                id: nome
                //text: nome_txt
                textStyle.fontSize: FontSize.Medium
                textStyle.fontWeight: FontWeight.W500
                textStyle.color: Color.create(color)
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Left
            }
        }
        
        Container {
            layoutProperties: StackLayoutProperties {
                spaceQuota: 3.0
            
            }
            Label {
                id: dest
                //text: dest_txt
                textStyle.color: Color.create(color)
                textStyle.fontSize: FontSize.PointValue
                horizontalAlignment: horizontalAlignment.Left
                textStyle.fontSizeValue: 6.5
            multiline: true
            autoSize.maxLineCount: 3
        }
        }
        
        Container{
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.5
            
            }
        verticalAlignment: VerticalAlignment.Center
        Label {
                id: orario
                //text: orario_txt
                textStyle.fontSize: FontSize.Medium
                textStyle.fontWeight: FontWeight.W500
                textStyle.color: Color.create(color)
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Fill
            textStyle.textAlign: TextAlign.Left
        }
        }
        
        Container{
            layoutProperties: StackLayoutProperties {
                spaceQuota: 0.8
            
            }
        verticalAlignment: VerticalAlignment.Center
        Label {
                id: binario
                //text: binario_txt
                textStyle.fontSize: FontSize.Medium
                textStyle.textAlign: TextAlign.Center
            //textStyle.fontWeight: FontWeight.W500
                textStyle.color: Color.create(color)
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        
        Container{
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.2
            
            }
        rightPadding: ui.du(0.0)
        rightMargin: ui.du(0.0)
        layout: DockLayout {

        }
        leftPadding: ui.du(0.0)
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftMargin: ui.du(0.0)
        Container{
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            leftPadding: ui.du(1.0)
            bottomPadding: ui.du(0.0)
            rightPadding: ui.du(0.0)
            topPadding: ui.du(0.0)
            topMargin: ui.du(0.0)
            rightMargin: ui.du(0.0)
            bottomMargin: ui.du(0.0)
            leftMargin: ui.du(0.0)
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            ImageView {
                    id: image
                    verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                scaleX: 1.5
                scaleY: 1.5
                scalingMethod: ScalingMethod.AspectFill
                //rightMargin: ui.du(0.0)
                //leftMargin: ui.du(0.0) 
    
            }
                Label {
                    id: ritardo
                    //text: ritardo_txt
                    textStyle.fontSize: FontSize.Medium
                    textStyle.fontWeight: FontWeight.W500
                    textStyle.color: Color.create(color)
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                leftMargin: ui.du(1.0)
                rightMargin: ui.du(0.0)
            }
            
    }}
        
        /*attachedObjects: [
            ImagePaintDefinition {
                id: bg
                repeatPattern: RepeatPattern.X
                imageSource: "asset:///images/bg.png"
            }
        ]*/
    topPadding: ui.du(1.5)
}

