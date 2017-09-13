import bb.cascades 1.4
//import QtQuick 1.0



Page {
    Container {
        //property string primaryWhite: "#F0F0F0"
        //background: Color.create("#111111")
        background: ui.palette.background
Titolo {
    text: "Dettagli soluzione"
}
        
        Container {
            preferredWidth: Infinity
            //background: Color.create("#111111")
            topPadding: ui.du(1.0)
            leftPadding: ui.du(1.0)
            rightPadding: ui.du(1.0)
            bottomPadding: ui.du(1.5)
            Label {
                text: "Durata complessiva del viaggio: " + tl.dati.duration
                //textStyle.color: Color.create(primaryWhite)
                textStyle.fontSize: FontSize.Medium

            }
            Label {
                text: {
                    if(tl.dati.saleable)
                        "Prezzo a partire da: " + parseFloat(tl.dati.minprice).toFixed(2) + "€"
                    else
                        "Soluzione non acquistabile"}
                //textStyle.color: Color.create(primaryWhite)
                textStyle.fontSize: FontSize.Medium
                topMargin: ui.du(0.0)

            }
        }
        //-----------------------------------------
        // color palette test section
        /*Container {
            minHeight: ui.du(50)
            layout: DockLayout {}
            Container {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                Container {
                    background: ui.palette.primary
                    Label {
                        text: "Primary Dark" + Color.toHexString(ui.palette.primaryDark).toUpperCase();
                    }
                }                   
                Container {
                    background: ui.palette.primaryBase
                    Label {
                        text: "Primary Base " + Color.toHexString(ui.palette.se).toUpperCase();
                    }
                }
                Container {
                    background: ui.palette.primarySoft
                    Label {
                        text: "Primary Soft " + Color.toHexString(ui.palette.primarySoft).toUpperCase();
                    }
                }    
                Container {
                    background: ui.palette.background
                    Label {
                        text: "Background " + Color.toHexString(ui.palette.background).toUpperCase();
                    }
                }
                Container {
                    background: ui.palette.plain
                    Label {
                        text: "Plain " + Color.toHexString(ui.palette.plain).toUpperCase();
                    }
                }
                Container {
                    background: ui.palette.plainBase
                    Label {
                        text: "Plain Base" + Color.toHexString(ui.palette.plainBase).toUpperCase();
                    }
                }
            }
        }*/
        
        //-----------------------------------------
        ListView {
        id: lista
        dataModel: _artifactline.solutionDetails
        listItemComponents: [

            ListItemComponent {
                type: "item"
                Container {
                    id: itemRoot
                    
                    preferredWidth: Infinity
                    preferredHeight: ui.ddu(20.5)
                    //pref height du 18
                    //maxHeight: ui.du(18)
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    background: bg.imagePaint
                    
                    attachedObjects: [
                        ImagePaintDefinition {
                            id: bg
                            repeatPattern: RepeatPattern.X
                            imageSource: "asset:///images/bg.png"
                        }
                    ]
                        
                    Container {
                        //max height du 18
                        preferredHeight: ui.ddu(20.5)
                        horizontalAlignment: HorizontalAlignment.Left
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        layout: StackLayout {
                            orientation: LayoutOrientation.TopToBottom
                        }
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 6.0
                        }
                        
                        Label {
                            id: orarioPartenza
                            horizontalAlignment: HorizontalAlignment.Left
                            verticalAlignment: VerticalAlignment.Top
                            function getOrarioPartenza(){
                                var d = new Date(ListItemData.departuretime);
                                var min = d.getMinutes().toString();
                                if (min < 10)
                                    min = "0" + min;
                                return d.getHours()+":"+min + " " + ListItemData.departurestation.toUpperCase();
                                }
                            text: getOrarioPartenza();
                            textStyle {
                                base: SystemDefaults.TextStyles.PrimaryText
                                color: Color.Black
                            }
                            multiline: false
                            //textStyle.fontWeight: FontWeight.Bold
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 2
                            }
                            bottomMargin: ui.du(0)
                            textStyle.fontWeight: FontWeight.W500
                            textStyle.fontSize: FontSize.Large
                        }
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            
                            }
                            
                            topMargin: ui.du(0.0)
                            topPadding: ui.du(0.0)
                            leftPadding: ui.du(1.5)
                            rightPadding: ui.du(0.0)
                            bottomPadding: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                            rightMargin: ui.du(0.0)
                            leftMargin: ui.du(0.0)
                            
                            ImageView {
                                imageSource: ListItemData.traintype == "italo" ? "asset:///images/italo_logo_red.png" : "asset:///images/fs_logo.png"
                                scalingMethod: ScalingMethod.AspectFit
                                loadEffect: ImageViewLoadEffect.None
                                verticalAlignment: VerticalAlignment.Center
                                leftMargin: ui.ddu(2.0)
                                
                                preferredHeight: ListItemData.traintype == "italo" ? ui.ddu(3.5) : ui.ddu(3)
                            }
                            
                            Label {
                                id: treno
                                text: {""+ListItemData.trainacronym + " " + ListItemData.trainidentifier.replace(/\s+/g, " ");}
                                textStyle {
                                    base: SystemDefaults.TextStyles.SmallText
                                    color: Color.DarkGray
                                    fontSize: FontSize.Small
                                }
                                multiline: true
                                textFit.minFontSizeValue: 6.0
                                verticalAlignment: VerticalAlignment.Fill
                                horizontalAlignment: HorizontalAlignment.Fill
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                
                            topMargin: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                            leftMargin: ui.du(2.0)
                            textFit.mode: LabelTextFitMode.FitToBounds
                            }
                        }
                                Label {
                                    id: durata
                                    text: "  Durata: " + ListItemData.duration
                                    textStyle {
                                        base: SystemDefaults.TextStyles.SmallText
                                        color: Color.DarkGray
                                        fontSize: FontSize.Small
                                    }
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                    multiline: true
                                    textFit.minFontSizeValue: 6.0
                                    verticalAlignment: VerticalAlignment.Fill
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    topMargin: ui.du(0.0)
                                    bottomMargin: ui.du(0.0)
                                    leftMargin: ui.du(2.0)
                                }
                        
                        
                        Label {
                            function getOrarioArrivo(){
                                var d = new Date(ListItemData.arrivaltime);
                                var min = d.getMinutes().toString();
                                if (min < 10)
                                    min = "0" + min;
                                return d.getHours()+":"+min + " " + ListItemData.arrivalstation.toUpperCase();
                            }
                            
                            id: orarioArrivo
                            text: getOrarioArrivo();
                            //text: getOrarioArrivo();
                            //textStyle.fontWeight: FontWeight.Bold
                            textStyle.color: Color.Black
                            textStyle.base: SystemDefaults.TextStyles.TitleText
                            verticalAlignment: VerticalAlignment.Bottom
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 2
                            }
                            bottomMargin: ui.du(0.0)
                            topMargin: ui.du(0)
                            textStyle.fontWeight: FontWeight.W500
                        
                        }
                    }

                }
                
            }
        ]
        }
    }
    actions: [
        InvokeActionItem {
            query{
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
                data: "Partenza alle "+ tl.dati.orarioPartenza +" da " +tl.dati.origin + "\nTreno " + tl.dati.numeroTreno.toString().replace(",", " / ") + "\nArrivo alle " + tl.dati.orarioArrivo+ " a " + tl.dati.destination + ( tl.dati.saleable ? "\nCosto minimo: " + parseFloat(tl.dati.minprice).toFixed(2) +" Euro" : "\nNon acquistabile")
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            id: pagah
            title: "Acquisto"
            enabled: tl.dati.saleable
            imageSource: "asset:///images/ic_open.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                _artifactline.pagah(tl.index)
            }
        },
        ActionItem {
            id: salva
            title: "Salva"
            imageSource: "asset:///images/calendar-add-256x256.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                _artifactline.salvaEvento(tl.index)
            }
        }
    ]
}
    

