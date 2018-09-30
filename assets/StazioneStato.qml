import bb.cascades 1.4

Page {
    property string searchedTrain
    
    function pushPane() {
        wait.close();
        if (parseInt(searchedTrain) > 9900 && parseInt(searchedTrain) < 9999) {
            var page = statoTrenoPageItalo.createObject()
            navigationPane.push(page)
        } else {
            var page = statoTrenoPage.createObject()
            navigationPane.push(page)
        }
        page.numeroTreno = searchedTrain     //save it for the refresh button
        _artifactline.salvaRicerca(searchedTrain)
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
    
    onCreationCompleted: {
        _artifactline.statusDataLoaded.connect(pushPane)
    }
    
    Container {
        background: Color.create("#e3e3e3")
        Titolo {
            text: "Stazione di " + stazionericerca.nome.charAt(0) + stazionericerca.nome.slice(1).toLowerCase()
        }
        Container {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill

            StazioneItem {
                codice: "Treno"
                dest: "Destinazione"
                orario: "Ora"
                binario: "Bin."
                //ritardo: ListItemData.status
                ritardo: "Rit."
                color: "#f0f0f0"
                bg: Color.create("#006263")
            }

            ListView {
                id: lista
                objectName: "lista"
                dataModel: _artifactline.stazioneStatus

                onTriggered: {
                    clearSelection();
                    select(indexPath);
                    
                    var num = dataModel.data(indexPath).numeroTreno
                    searchedTrain = num
                    
                    if(parseInt(num) > 9900 && parseInt(num) < 9999)
                        _artifactline.requestStatusDataItalo(num)
                    else
                        _artifactline.requestStatusData(num)
                        
                    wait.open()
                }

                listItemComponents: [
                    ListItemComponent {
                        type: "item"
                        Container {
                            id: itemRoot
                            preferredWidth: Infinity
                            //preferredHeight: ui.ddu(20.5)
                            //pref height du 18
                            //maxHeight: ui.du(18)

                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }

                            StazioneItem {
                                codice: ListItemData.compNumeroTreno //tipo + numero
                                dest: (ListItemData.destinazioneEstera != null && ListItemData.destinazioneEstera != "") ? ListItemData.destinazioneEstera : ListItemData.destinazione
                                orario: ListItemData.orarioPartenza
                                binario: ListItemData.binarioEff != "" ? ListItemData.binarioEff : ListItemData.binarioProg
                                //ritardo: ListItemData.status
                                ritardo: {
                                    if(ListItemData.ritardo != "0")
                                        return ListItemData.ritardo + "'"
                                    else if(ListItemData.image)
                                        return ""
                                    else return "n/a"
                                    }
                                image: "asset:///images" + ListItemData.image
                                color: "#000000"
                                bg: itemRoot.ListItem.indexPath % 2 ? Color.create("#ffffff") : Color.create("#eeeeee")
                            }

                            //background: ListItem.indexPath % 2 ? Color.create("#ffffff") : Color.create("#eeeeee")

                        }
                    }
                ]
            }
        }
    }
}
