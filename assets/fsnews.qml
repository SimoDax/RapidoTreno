import bb.cascades 1.4
import "utils.js" as Utils

Page {
    onCreationCompleted: {
        _artifactline.newsLoaded.connect(chiudi);
        wait.open();
        _artifactline.requestFSNews();
    }
    function chiudi() {
        wait.close();
        //wait.destroy();
    }

    Container {
        Titolo {
            text: "Infomobilità"
        }
        ListView {
            id: statoView
            dataModel: _artifactline.news
            listItemComponents: [
                ListItemComponent {
                    type: "item"
                    //title: ListItemData.titolo
                    //description: getDate(ListItemData.ora) + " " + ListItemData.testo
                    /*Label {
                     * text: "lol"
                     }*/

                    Container {
                        //background: item.ListItem.selected ? Color.create("#9975b5d3") : Color.Transparent
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        topPadding: ui.du(2.2)
                        //bottomPadding: ui.du(2.2)
                        //bottomMargin: ui.du(2.2)
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        layout: StackLayout {
                        }
                        Label {
                            text: "<html><span style='text-decoration:underline'>" + ListItemData.title + "</span></html>"
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontWeight: FontWeight.W500
                            textStyle.color: Application.themeSupport.theme.colorTheme.primary

                            multiline: true
                            textFormat: TextFormat.Html
                        }
                        Label {
                            text: Utils.getDate(ListItemData.pubDateEng);
                            multiline: true
                        }
                        Divider {
                            topMargin: ui.du(2.2)
                        }
                    }

                }

            ]
            onTriggered: {
                openlink.query.setUri(dataModel.data(indexPath).link);
                openlink.trigger("bb.action.OPEN");
                clearSelection();
            }

            attachedObjects: Invocation {
                id: openlink
                query {
                    invokeTargetId: "sys.browser"
                    onQueryChanged: {
                        openlink.query.updateQuery();
                    }
                }
            }
        }

    }
    attachedObjects: [
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
    ]
}
