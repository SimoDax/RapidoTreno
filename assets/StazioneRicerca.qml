import bb.cascades 1.4
import bb.system 1.2
import Storage.LocalDataManager 1.0

NavigationPane {
    id: navigationPane
    onPopTransitionEnded: page.destroy()
    signal tapped()
    Page {
        property string codice
        property bool ready: false
        property alias nome: numtreno.text
        property alias waiter: wait

        id: stazionericerca

        function pushPane() {
            wait.close()
            navigationPane.push(statoTrenoPage.createObject())
        }
        
        function errorDialog(errorMessage) {
            wait.close()
            myQmlToast.body = errorMessage
            myQmlToast.show()
        }
        
        function aborted() {
            wait.close()
        }

        onCreationCompleted: {
            _artifactline.stationDataLoaded.connect(pushPane)
            _artifactline.badResponse.connect(errorDialog)
            //_artifactline.abort.connect(aborted);
        }
        
        Container {
            Titolo {
                text: "Cerca Stazione"
            }

            Container {
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(2.2)
                topPadding: ui.du(2.2)
                bottomPadding: ui.du(2.2)
                verticalAlignment: VerticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Fill
                bottomMargin: ui.du(0.0)
                Label {
                    text: "Stazione: "
                    textStyle.fontSize: FontSize.Large

                }
                TextField {
                    id: numtreno
                    hintText: "Nome stazione"
                    //inputMode: TextFieldInputMode.PhoneNumber
                    input {
                        flags: TextInputFlag.Prediction
                    }
                    /*onFocusedChanged: {
                     * if(focused)
                     * ricerche.visible = true;
                     }*/
                    /*onTextChanging: {
                     * if(text!="")
                     * cerca.enabled = true;
                     * else cerca.enabled = false;
                     }*/
                    onTextChanging: {
                        if (focused == true) {
                            //main.a_ready = false;
                            stazlist.load(text.trim());

                        }
                    }
                    onFocusedChanged: {
                        if (focused == true) {
                            stazionericerca.ready = false;
                            listContainer.minHeight = ui.du(80);
                            l_a.visible = true;
                            stazlist.load(text.trim());
                        }
                    }
                }

            }
            Container {
                id: listContainer
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: ui.du(1.0)
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(2.2)
                bottomPadding: ui.du(2.2)
                layout: StackLayout {

                }

                ListView {
                    id: l_a
                    dataModel: stazlist.stazioni
                    minHeight: ui.du(30.0)
                    maxHeight: ui.du(40.0)
                    visible: false
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(0.0)
                    topMargin: ui.du(0.0)

                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            Container {
                                id: _itemRoot
                                minWidth: ui.du(30)
                                background: _itemRoot.ListItem.active ? Color.LightGray : SystemDefaults.Paints.ContainerBackground
                                layout: StackLayout {

                                }
                                preferredWidth: Infinity
                                topPadding: ui.du(1)
                                leftPadding: ui.du(2.0)
                                bottomPadding: ui.du(1)
                                Label {
                                    id: _s
                                    horizontalAlignment: HorizontalAlignment.Left
                                    verticalAlignment: VerticalAlignment.Center
                                    topMargin: ui.du(0.0)
                                    bottomMargin: ui.du(0.0)
                                    text: ListItemData.name
                                    textStyle {
                                        base: SystemDefaults.TextStyles.PrimaryText
                                        color: (_itemRoot.ListItem.selected || _itemRoot.ListItem.active) ? Color.Black : Color.LightGray
                                    }
                                    multiline: false
                                }
                            }
                        }
                    ]
                    onTriggered: {
                        var selectedItem = dataModel.data(indexPath);
                        stazionericerca.codice = selectedItem.codice;
                        numtreno.text = selectedItem.name;
                        l_a.visible = false;
                        //screenName.visible = true;
                        //da.visible = true;
                        listContainer.minHeight = ui.du(0);
                        stazionericerca.ready = true
                    }
                    //leftMargin: ui.du(5.0)
                    //leftPadding: ui.du(5.0)
                }
            }
        }
        actions: [
            ActionItem {
                id: cerca
                title: "Cerca"
                ActionBar.placement: ActionBarPlacement.Signature
                //enabled: numtreno.text.trim() != ""
                enabled: stazionericerca.ready
                imageSource: "asset:///images/ic_search.png"

                onTriggered: {
                    //_artifactline.salvaRicerca(numtreno.text);
                    if (numtreno.text != "") {
                        _artifactline.requestStation(stazionericerca.codice);
                        wait.open();
                    }
                }

                attachedObjects: ComponentDefinition {
                    id: statoTrenoPage
                    source: "StazioneStato.qml"
                }
            }
        ]
    }
    attachedObjects: [
        LocalDataManager {
            id: stazlist
        },
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
        },
        SystemToast {
            id: myQmlToast
            body: "Errore nell'elaborazione della richiesta"
        }
    ]
}
