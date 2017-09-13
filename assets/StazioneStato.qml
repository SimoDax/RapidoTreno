import bb.cascades 1.4

Page {
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

                //onTriggered: navPane.tapped()

                onTriggered: {
                    clearSelection();
                    select(indexPath);
                    tabbedPane.fromStationToTrain(dataModel.data(indexPath).numeroTreno);
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
                                ritardo: ListItemData.ritardo != "0" ? (ListItemData.ritardo + "'") : ""
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
