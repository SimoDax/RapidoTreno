import bb.cascades 1.4

Page {
    Container {
        background: Color.create("#e3e3e3")
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
            }
            Container {
                id: titolo
                minHeight: ui.du(10.0)
                maxHeight: ui.du(10.0)
                background: redgrad.imagePaint
                horizontalAlignment: HorizontalAlignment.Fill
                attachedObjects: [
                    ImagePaintDefinition {
                        id: redgrad
                        repeatPattern: RepeatPattern.X
                        imageSource: "asset:///images/redgrad.png"
                    }
                ]
                Container {
                    topPadding: ui.du(2.0)
                    leftPadding: ui.du(2.2)
                    rightPadding: ui.du(2.2)
                    bottomPadding: ui.du(2.2)
                    Label {
                        text: "Stato Tren " + _artifactline.requestStatusField("compNumeroTreno")
                        textStyle.color: Color.White
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Fill
                        textStyle.fontSize: FontSize.Large
                        textStyle.fontWeight: FontWeight.W500
                    }
                }
            }
                Container {
                    id: ricerca
                    minHeight: ui.du(5)
                    maxHeight: ui.du(5)
                    background: Color.create("#006263")
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Top
                    leftPadding: ui.du(2.2)
                    //rightPadding: ui.du(2.2)
                    topPadding: ui.du(0.5)
                    //bottomPadding: ui.du(2)
                    Label {
                        text: _artifactline.requestStatusField("compTipologiaTreno").charAt(0).toUpperCase()+_artifactline.requestStatusField("compTipologiaTreno").slice(1)+ " delle " + _artifactline.requestStatusField("compOrarioPartenza") + " da "+_artifactline.requestStatusField("origine")+" a "+_artifactline.requestStatusField("destinazione")
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
            layoutProperties: StackLayoutProperties {
            spaceQuota: 1
            }
            /*Header {
                title: "Informazioni in tempo reale"
            }*/
            Container {
                id: statusCont
                topPadding: ui.du(2.2)
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(2.2)
                //bottomPadding: ui.du(2.2)
                Label {
                    property bool displayRiv: true
                    //signal done()
                        function getStatus(){
                        var tipoTreno = _artifactline.requestStatusField("tipoTreno");
                        var hasProvvedimenti = _artifactline.requestStatusField("hasProvvedimenti");
                        if(tipoTreno == "PG" && hasProvvedimenti == false){
                            var stazUltRil = _artifactline.requestStatusField("stazioneUltimoRilevamento");
                            if(stazUltRil == "--")
                                {displayRiv = false; return "Il treno non è ancora partito";}
                            var stazDest = _artifactline.requestStatusField("destinazione");
                            var descRitardo = _artifactline.requestStatusField("compRitardoAndamento", 0);
                            if(stazUltRil == stazDest && descRitardo != null)
                                return "Il treno è giunto a destinazione " + descRitardo;
                            var ritardo = _artifactline.requestStatusField("compImgRitardo");
                            if (ritardo == "/vt_static/img/legenda/icone_legenda/regolare.png" && descRitardo == null)
                                return "Il treno viaggia in orario";
                            else
                                return "Il treno viaggia " + descRitardo;
                            }
                        else{
                            var provvedimento = _artifactline.requestStatusField("provvedimento");
                            if(tipoTreno == "ST" && provvedimento == 1){
                                displayRiv = false;
                                return "Il treno è stato soppresso"
                            }
                            else if (tipoTreno == "DV" && provvedimento == 3)
                                return "Il treno è stato deviato"
                            else if ((tipoTreno == "PP" || tipoTreno == "SI" || tipoTreno == "SF")&&(provvedimento==0 || provvedimento==2))
                                return "Il treno è stato parzialmente soppresso, consultare l'elenco fermate"
                            }
                        //done();
                    }
                    id: status
                    text: getStatus()
                    textStyle.fontSize: FontSize.Medium
                    textStyle.color: Color.Black
                    bottomMargin: ui.du(0.0)
                }
                Label {
                    function getRil(){
                        if(status.displayRiv == true){
                            var d = new Date(_artifactline.requestStatusField("oraUltimoRilevamento"));
                            var min = d.getMinutes().toString();
                            if (min < 10)
                            min = "0" + min;
                            return "Ultimo rilvamento a " + _artifactline.requestStatusField("stazioneUltimoRilevamento") + " alle  " + d.getHours().toString()+":"+min;}
                    }
                    onCreationCompleted: {
                            if(status.displayRiv == false)
                                statusCont.remove(ril);
                                contCont.layoutProperties.spaceQuota = 0.5;
                        }
                    
                    id: ril
                    text: getRil()
                    visible: true
                    textStyle.color: Color.Black
                    bottomMargin: ui.du(0.0)
                    
                }
            }
        }
        Divider {

        }
        Container {
            layout: StackLayout {}
            layoutProperties: StackLayoutProperties {
                spaceQuota: 4
            }

            ScrollView {
                scrollViewProperties.scrollMode: ScrollMode.Vertical
                scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll
                Container {
                    Header {
                        title: "Stazione di Partenza"
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
                        id: part
                        topPadding: ui.du(1.0)
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        bottomPadding: ui.du(1.0)
                        horizontalAlignment: HorizontalAlignment.Fill
                        Label {
                            text: _artifactline.requestStatusField("origine");
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontWeight: FontWeight.W500
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                        }
                        Label {
                            text: "Partenza programmata: " + _artifactline.requestStatusField("compOrarioPartenza");
                            bottomMargin: ui.du(0.5)
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.5)
                            leftMargin: ui.du(0.6)
                        }
                        Label {
                            text: "Partenza effettiva: " + (_artifactline.requestStatusField("fermate", 0, "partenzaReale")!=null ? cont.getDate(_artifactline.requestStatusField("fermate", 0, "partenzaReale")) : "--")
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                            leftMargin: ui.du(0.6)
                        }
                    }
                    Header{
                        title: "Fermate intermedie:"
                    }
                    Container {
                        id: cont
                        attachedObjects: [
                            ComponentDefinition{
                                id: fermatadetail
                                source: "asset:///FermataDetail.qml"
                            }
                        ]
                        function getDate(s){
                            var d = new Date(s);
                            var min = d.getMinutes().toString();
                            if (min < 10)
                                min = "0" + min;
                            return d.getHours()+":"+min;
                        }
                        
                        function populate(){
                            if(_artifactline.requestStatusField("nFermate") >= 3){
                            for(var i=1; i<_artifactline.requestStatusField("nFermate")-1; i++){
                                var component = fermatadetail.createObject();
                                var fermatatType = _artifactline.requestStatusField("fermate", i, "actualFermataType")
                                if(fermatatType == 3){
                                    component.arrProg_txt = getDate(_artifactline.requestStatusField("fermate", i, "arrivo_teorico"));
                                    component.partProg_txt = getDate(_artifactline.requestStatusField("fermate", i, "partenza_teorica"));
                                    component.arrEff_txt = "--";
                                    component.partEff_txt = "--";
                                    component.or_txt = "--";
                                    component.bin_txt = "--";
                                    component.nome_txt = _artifactline.requestStatusField("fermate", i, "stazione") + " >SOPPRESSA<";
                                }
                                else{
                                    component.arrProg_txt = getDate(_artifactline.requestStatusField("fermate", i, "arrivo_teorico"));
                                    component.partProg_txt = getDate(_artifactline.requestStatusField("fermate", i, "partenza_teorica"));
                                    var arrEff = _artifactline.requestStatusField("fermate", i, "arrivoReale");
                                    if(arrEff != null)
                                        component.arrEff_txt = getDate(arrEff);
                                    else
                                        component.arrEff_txt = "--"
                                    var partEff = _artifactline.requestStatusField("fermate", i, "partenzaReale");
                                    if(partEff != null)
                                        component.partEff_txt = getDate(partEff);
                                    else
                                        component.partEff_txt = "--"
                                    component.bin_txt = _artifactline.requestStatusField("fermate", i, "binarioProgrammatoArrivoDescrizione").toString().trim();
                                    var or = _artifactline.requestStatusField("fermate", i, "binarioEffettivoArrivoDescrizione");
                                    if(or != null)
                                        component.or_txt = or;
                                    else 
                                        component.or_txt = "--";
                                    component.nome_txt = _artifactline.requestStatusField("fermate", i, "stazione");
                                }
                                cont.add(component);
                            }
                        }
                        }
                        
                        onCreationCompleted: {
                            populate();
                        }
                }
            
                    Header {
                        title: "Stazione di Arrivo"
                    }
                    Container {
                        background: bg_.imagePaint
                        
                        attachedObjects: [
                            ImagePaintDefinition {
                                id: bg_
                                repeatPattern: RepeatPattern.X
                                imageSource: "asset:///images/bg.png"
                            }
                        ]
                        id: arr
                        topPadding: ui.du(1.0)
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        bottomPadding: ui.du(1.0)
                        horizontalAlignment: HorizontalAlignment.Fill
                        Label {
                            text: _artifactline.requestStatusField("destinazione");
                            textStyle.fontSize: FontSize.Medium
                            textStyle.color: Color.Black
                            textStyle.fontWeight: FontWeight.W500
                            bottomMargin: ui.du(0.0)
                            topMargin: ui.du(0.0)
                        }
                        Label {
                            text: "Arrivo programmato: " + _artifactline.requestStatusField("compOrarioArrivo");
                            bottomMargin: ui.du(0.5)
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.5)
                        }
                        Label {
                            text: "Arrivo previsto: " + (_artifactline.requestStatusField("fermate", _artifactline.requestStatusField("nFermate")-1, "arrivoReale")!=null ? cont.getDate(_artifactline.requestStatusField("fermate", _artifactline.requestStatusField("nFermate")-1, "arrivoReale")) : "--")
                    textStyle.color: Color.Black
                            bottomMargin: ui.du(0.0)
                            topMargin: ui.du(0.0)
                        }
                    }
                }
            }
        }
    }
}

