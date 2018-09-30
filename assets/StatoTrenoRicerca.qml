import bb.cascades 1.4
import bb.system 1.2

NavigationPane {
    id: navigationPane
    onPopTransitionEnded: page.destroy()

    Page {
        id: statoricerca
        
        function pushPane() {
            //_artifactline.salvaRicerca(numtreno.text.trim());
            wait.close();
            if ((parseInt(numtreno.text) > 9900 && parseInt(numtreno.text) < 9999) || (parseInt(numtreno.text) > 8900 && parseInt(numtreno.text) < 8999)){
                var page = statoTrenoPageItalo.createObject();
                navigationPane.push(page);
            }
            else{
                var page = statoTrenoPage.createObject();
                navigationPane.push(page);
            }
            page.numeroTreno = numtreno.text.trim();
            _artifactline.salvaRicerca(numtreno.text.trim());
        }
        
        function errorDialog(errorMessage) {
            wait.close();
            myQmlToast.body = errorMessage;
            myQmlToast.show();
        }
        
        function aborted() {
            wait.close();
        }
        
        function setDataModel() {
            ricerche.dataModel = _artifactline.ricerche;
        }
        
        onCreationCompleted: {
            _artifactline.statusDataLoaded.connect(pushPane);
            _artifactline.badResponse.connect(errorDialog);
            _artifactline.abort.connect(aborted);
            //_artifactline.ricercheLoaded.connect(setDataModel);
            _artifactline.caricaRicerche();
        }
        
        Container {
            //background: Color.create("#111111")
            Titolo {
                text: "Stato Treno"
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
                    text: "Numero treno: "
                    textStyle.fontSize: FontSize.Large

                }
                TextField {
                    id: numtreno
                    hintText: "Numero treno"
                    inputMode: TextFieldInputMode.PhoneNumber
                    input {
                        flags: TextInputFlag.Prediction
                    }
                    onFocusedChanged: {
                        if (focused)
                            ricerche.visible = true;
                    }
                    onTextChanging: {
                        if (text != "")
                            cerca.enabled = true;
                        else cerca.enabled = false;
                    }
                    /* onTextChanging: {
                     * if (focused == true) {
                     * //main.a_ready = false;
                     * if(text != "")
                     * _artifactline.caricaStazioni(text.trim());
                     * else _artifactline.resetStazioni();
                     * }
                     * }
                     * onFocusedChanged: {
                     * if(focused == true)
                     * {
                     * listContainer.minHeight = ui.du(80);
                     * l_a.visible = true;
                     * _artifactline.resetStazioni();
                     * if(text.trim() != "")
                     * _artifactline.caricaStazioni(text.trim());
                     * }
                     }*/
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
                    dataModel: _artifactline.stazioni
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
                                //background: _itemRoot.ListItem.active ? Color.LightGray : SystemDefaults.Paints.ContainerBackground
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
                                        //color: (_itemRoot.ListItem.selected || _itemRoot.ListItem.active) ? Color.Black : Color.LightGray
                                    }
                                    multiline: false
                                }
                            }
                        }
                    ]
                    onTriggered: {
                        var selectedItem = dataModel.data(indexPath);
                        numtreno.text = selectedItem.name;
                        l_a.visible = false;
                        listContainer.minHeight = ui.du(0);

                    }
                    //leftMargin: ui.du(5.0)
                    //leftPadding: ui.du(5.0)
                }
            }
            Container {
                //background: Color.create("#123456")
                ListView {
                    id: ricerche
                    dataModel: _artifactline.ricerche
                    preferredWidth: Infinity
                    preferredHeight: ui.du(50)
                    visible: true
                    onTriggered: {
                        numtreno.text = dataModel.data(indexPath);
                        //visible = false;
                    }
                }
            }
        }
        actions: [
            ActionItem {
                id: cerca
                title: "Cerca"
                ActionBar.placement: ActionBarPlacement.Signature
                enabled: numtreno.text.trim() != ""
                imageSource: "asset:///images/ic_search.png"

                onTriggered: {
                    if (numtreno.text != "") {
                        //statoricerca.num = numtreno.text.trim();

                        if (parseInt(numtreno.text) > 8900 && parseInt(numtreno.text) < 9999)
                            _artifactline.requestStatusDataItalo(numtreno.text.trim());
                        else
                            _artifactline.requestStatusData(numtreno.text.trim());

                        wait.open();
                    }
                }

                attachedObjects: [
                    ComponentDefinition {
                        id: statoTrenoPage
                        source: "StatoTreno.qml"
                    },
                    ComponentDefinition {
                        id: statoTrenoPageItalo
                        source: "StatoTrenoItalo.qml"
                    }
                ]

            }
        ]

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
            },
            SystemToast {
                id: myQmlToast
                body: "Errore nell'elaborazione della richiesta"
            }
        ]
    }

}