import bb.cascades 1.4

Dialog {
    id: wait
    onOpened: {
        indicator.start();
    }
    onClosed: {
        indicator.stop();
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.create(0.0, 0.0, 0.0, 0.7)
        ActivityIndicator {
            id: indicator
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            preferredWidth: Infinity
            preferredHeight: Infinity
        }
    }
}