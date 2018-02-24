import bb.cascades 1.4

Page {
    property string numeroTreno
    Container {
        background: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#e3e3e3") : null
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        Titolo {
            text: "Stato Treno " + _artifactline.statusData.numTreno
        }
        Container {
            id: ricerca
            minHeight: ui.ddu(5)
            maxHeight: ui.ddu(5)
            // min e max h 5 du
            background: Color.create("#006263")
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            leftPadding: ui.du(2.2)
            //rightPadding: ui.du(2.2)
            topPadding: ui.du(0.5)
            //bottomPadding: ui.du(2)
            Label {
                text: _artifactline.statusData.info
                //text: "Prova"
                //textFit.mode: LabelTextFitMode.FitToBounds
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                textStyle.color: Color.White
                //topMargin: ui.du(0.5)
                //bottomMargin: ui.du(0.0)
                textStyle.fontSize: FontSize.XSmall
            
            }
        }
        
        Container {
            id: contCont
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            /*layoutProperties: StackLayoutProperties {
             spaceQuota: 1.5
             }*/
/*Header {
 title: "Informazioni in tempo reale"
 }*/
            Container {
                id: statusCont
                topPadding: ui.du(1.5)
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(0.5)
                bottomPadding: ui.du(1.5)
                Label {
                    property bool displayRiv: true
                    //signal done()
                    function getStatus(){
                        //return "Prova"
                            return "Il treno viaggia in " + _artifactline.statusData.stato.toString().toLowerCase().trim().replace("in ", "")
                        }
                        //done();
                    
                    id: status
                    text: getStatus()
                    textStyle.fontSize: FontSize.Medium
                    textStyle.color:  Color.Black 
                    bottomMargin: ui.du(0.0)
                    textStyle.fontWeight: FontWeight.W500
                }
                Label {
                    function getRil(){
                        return "";
                    }
                    onCreationCompleted: {
                        //if(status.displayRiv == false)
                            statusCont.remove(ril);
                        //contCont.layoutProperties.spaceQuota = 0.65;
                    }
                    
                    id: ril
                    text: getRil()
                    visible: true
                    textStyle.color: Color.Black
                    bottomMargin: ui.du(1)
                    topMargin: ui.du(1)
                }
            }
            Header {
                title: "Prossima stazione"
            }
            Container {
                background: bg.imagePaint
                
                attachedObjects: [
                    ImagePaintDefinition {
                        id: bg
                        repeatPattern: RepeatPattern.X
                        imageSource: "asset:///images/bg.png"
                    }
                ]
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                leftPadding: ui.du(1.5)
                rightPadding: ui.du(0)
                bottomPadding: ui.du(1.0)
                Label {
                    text: _artifactline.statusData.next
                    textStyle.fontSize: FontSize.Medium
                    textStyle.fontWeight: FontWeight.W500
                    textStyle.color: Color.Black
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    
                    }
                    Container {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.5
                        }
                        leftPadding: ui.du(0.6)
                        Label {
                            
                            function part(){
                                if(_artifactline.statusData.partenzaProg != null)
                                    return "\nPartenza programmata: "+_artifactline.statusData.partenzaProg;
                                return "";
                            }
                            
                            text: "Arrivo programmato: "+_artifactline.statusData.arrivoProg+part();
                            multiline: true
                            textStyle.color: Color.Black
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6.5
                        }
                    }
                    Container {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        Label {
                            function part(){
                                if(_artifactline.statusData.partenzaEff != null)
                                    return "\nPrevista: "+_artifactline.statusData.partenzaEff;
                                return "";
                            }
                            text: "Previsto: "+_artifactline.statusData.arrivoEff+part();
                            multiline: true
                            textStyle.color: Color.Black
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6.5
                        }
                    }
                }
            }
        }
    }
    actions: [
        ActionItem {
            id: refresh
            title: "Aggiorna"
            imageSource: "asset:///images/ic_reload.png"
            ActionBar.placement: ActionBarPlacement.Signature
            onTriggered: {
                navigationPane.pop();
                wait.open();
                _artifactline.requestStatusData(numeroTreno);
            }
        }
    ]
    //actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Compact
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Default
}

