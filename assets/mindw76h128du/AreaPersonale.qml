import bb.cascades 1.4
import bb.system 1.2
import "utils.js" as Utils

Container {
    id: main
    Titolo {
        text: "Area Personale"
    }
    Container {
        leftPadding: ui.du(2.2)
        topPadding: ui.du(2.0)
        bottomPadding: ui.du(1.0)
        Label {
            text: "Benvenuto, " + _artifactline.profileData.name + " " + _artifactline.profileData.surname
        }
        Label {
            text: "Codice personale: " + _artifactline.profileData.cfcode
        }
        /*Label {
         * text: "E-mail: " + _artifactline.profileData.email
         }*/
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            topPadding: ui.du(1.5)
            Container {
                leftMargin: ui.du(2.2)
                ImageView {
                    function getSource() {
                        if (_artifactline.profileData.nextcftype == "Oro")
                            return "asset:///images/img_cartafr_base_red.gif";
                        else if (_artifactline.profileData.nextcftype == "Platino")
                            return "asset:///images/img_cartafr_oro.gif";
                        else
                            return "asset:///images/img_cartafr_platino.gif";
                    }
                    imageSource: getSource()
                }
            }
            Container {
                leftMargin: ui.du(2.2)
                Label {
                    text: "Saldo punti disponibili: " + _artifactline.profileData.points
                }
                Label {
                    text: "Hai " + _artifactline.profileData.nextpoints + " punti validi per Cartafreccia " + _artifactline.profileData.nextcftype
                }
            }
        }
    }
    Header {
        title: "Viaggi recentemente acquistati"
    }

    ListView {
        id: lista
        objectName: "lista"
        dataModel: _artifactline.tickets
        scrollRole: ScrollRole.Main

        function openpdf(ticket, tsid) {
            _artifactline.openTicket(ticket, tsid);
        }

        listItemComponents: [
            ListItemComponent {
                type: "item"

                Container {
                    id: itemRoot
                    background: bg.imagePaint
                    preferredWidth: Infinity
                    //preferredHeight: ui.ddu(20.5)
                    //pref height du 18
                    //maxHeight: ui.du(18)

                    ViaggioItem {
                        horizontalAlignment: HorizontalAlignment.Fill

                        function parseIsoDatetime(dtstr) {
                            var dt = dtstr.split(/[: T-]/).map(parseFloat);
                            var data = new Date(dt[0], dt[1] - 1, dt[2], dt[3] || 0, dt[4] || 0, dt[5] || 0, 0);
                            return data.getDate() + "/" + (parseInt(data.getMonth()) + 1).toString() + "/" + data.getFullYear() + " " + data.getHours() + ":" + data.getMinutes()
                        }

                        acquistato: "Acquistato il: " + Utils.parseIsoDate(ListItemData.purchasedate)
                        desc: ListItemData.traveldescription.toUpperCase()
                        data: "Data viaggio: " + Utils.parseIsoDate(ListItemData.departuredate)
                        type: "Tipologia: " + ListItemData.type
                        color: "#000000"

                    }

                    //background: ListItem.indexPath % 2 ? Color.create("#ffffff") : Color.create("#eeeeee")

                    attachedObjects: [
                        ImagePaintDefinition {
                            id: bg
                            repeatPattern: RepeatPattern.X
                            imageSource: "asset:///images/bg.png"
                        }
                    ]
                }
            }
        ]
    }

}