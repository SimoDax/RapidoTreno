import bb.cascades 1.4
import "utils.js" as Utils

Page {
    property string numeroTreno
    Container {
        background: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#e3e3e3") : null
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        Titolo {
            text: "Stato Treno " + _artifactline.requestStatusField("compNumeroTreno")
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
                text: _artifactline.requestStatusField("compTipologiaTreno").charAt(0).toUpperCase() + _artifactline.requestStatusField("compTipologiaTreno").slice(1) + " delle " + _artifactline.requestStatusField("compOrarioPartenza") + " da " + _artifactline.requestStatusField("origine") + " a " + _artifactline.requestStatusField("destinazione")
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
             * spaceQuota: 1.5
             }*/
            /*Header {
             * title: "Informazioni in tempo reale"
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
                    function getStatus() {
                        var tipoTreno = _artifactline.requestStatusField("tipoTreno");
                        var hasProvvedimenti = _artifactline.requestStatusField("hasProvvedimenti");
                        if (tipoTreno == "PG" && hasProvvedimenti == false) {
                            var stazUltRil = _artifactline.requestStatusField("stazioneUltimoRilevamento");
                            if (stazUltRil == "--") {
                                displayRiv = false;
                                return "Il treno non è ancora partito";
                            }
                            var stazDest = _artifactline.requestStatusField("destinazione");
                            var descRitardo = _artifactline.requestStatusField("compRitardoAndamento", 0);
                            if (stazUltRil == stazDest && descRitardo != null)
                                return "Il treno è giunto a destinazione " + descRitardo;
                            ////////////
                            if (stazUltRil == stazDest) return "Il treno è giunto a destinazione ";
                            ////////////
                            var ritardo = _artifactline.requestStatusField("compImgRitardo");
                            if (ritardo == "/vt_static/img/legenda/icone_legenda/regolare.png" && descRitardo == null)
                                return "Il treno viaggia in orario";
                            else
                                return "Il treno viaggia " + descRitardo;
                        } else {
                            var provvedimento = _artifactline.requestStatusField("provvedimento");
                            if (tipoTreno == "ST" && provvedimento == 1) {
                                displayRiv = false;
                                return "Il treno è stato soppresso"
                            } else if (tipoTreno == "DV" && provvedimento == 3)
                                return "Il treno è stato deviato";
                            else if ((tipoTreno == "PP" || tipoTreno == "SI" || tipoTreno == "SF" || tipoTreno == "RF") && (provvedimento == 0 || provvedimento == 2))
                                return "Il treno è stato parzialmente soppresso"
                        }
                        //done();
                    }
                    id: status
                    text: getStatus()
                    //textStyle.fontSize: FontSize.Medium
                    textStyle.color: Color.Black
                    bottomMargin: ui.du(0.0)
                }
                Label {
                    function getRil() {
                        if (status.displayRiv == true) {
                            var d = new Date(_artifactline.requestStatusField("oraUltimoRilevamento"));
                            var min = d.getMinutes().toString();
                            if (min < 10)
                                min = "0" + min;
                            if (_artifactline.requestStatusField("stazioneUltimoRilevamento") == null || isNaN(d.getHours()))
                                return "Ultimo rilevamento non disponibile"
                            return "Ultimo rilvamento a " + _artifactline.requestStatusField("stazioneUltimoRilevamento") + " alle " + d.getHours().toString() + ":" + min;
                        }
                    }
                    onCreationCompleted: {
                        if (status.displayRiv == false)
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
        }
        Container {
            layout: StackLayout {
            }
            layoutProperties: StackLayoutProperties {
                spaceQuota: 4
            }

            ScrollView {
                scrollViewProperties.scrollMode: ScrollMode.Vertical
                scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.Default
                scrollRole: ScrollRole.Main
                //preferredHeight: Infinity
                Container {
                    //preferredHeight: Infinity
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
                            text: _artifactline.requestStatusField("origineEstera") != null ? _artifactline.requestStatusField("origineEstera") : _artifactline.requestStatusField("origine")
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontWeight: FontWeight.W500
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                        }
                        Label {
                            text: " Partenza programmata: " + (_artifactline.requestStatusField("oraPartenzaEstera") != null ? Utils.getTime(_artifactline.requestStatusField("oraPartenzaEstera")) : _artifactline.requestStatusField("compOrarioPartenza"))
                            bottomMargin: ui.du(0.5)
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.5)
                            leftMargin: ui.du(0.6)
                        }
                        Label {
                            text: " Partenza effettiva: " + (_artifactline.requestStatusField("oraPartenzaEstera") != null ? "--" : (_artifactline.requestStatusField("fermate", 0, "partenzaReale") != null ? Utils.getTime(_artifactline.requestStatusField("fermate", 0, "partenzaReale")) : "--"))
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.0)
                            bottomMargin: ui.du(0.0)
                            leftMargin: ui.du(0.6)
                        }
                    }
                    Header {
                        title: "Fermate intermedie:"
                    }
                    Container {
                        id: cont
                        attachedObjects: [
                            ComponentDefinition {
                                id: fermatadetail
                                source: "asset:///FermataDetail.qml"
                            }
                        ]

                        function populate() {
                            if (_artifactline.requestStatusField("nFermate") >= 3) {
                                var nstaz = _artifactline.requestStatusField("nFermate");
                                var i_ = 0;
                                if (_artifactline.requestStatusField("destinazioneEstera") == null)
                                    nstaz --;
                                if (_artifactline.requestStatusField("origineEstera") == null)
                                    i_ ++;
                                for (var i = i_; i < nstaz; i ++) {
                                    var component = fermatadetail.createObject();
                                    var fermatatType = _artifactline.requestStatusField("fermate", i, "actualFermataType")
                                    if (fermatatType == 3) {
                                        component.arrProg_txt = Utils.getTime(_artifactline.requestStatusField("fermate", i, "arrivo_teorico"));
                                        component.partProg_txt = Utils.getTime(_artifactline.requestStatusField("fermate", i, "partenza_teorica"));
                                        component.arrEff_txt = "--";
                                        component.partEff_txt = "--";
                                        component.or_txt = "--";
                                        component.bin_txt = "--";
                                        component.nome_txt = _artifactline.requestStatusField("fermate", i, "stazione") + " >SOPPRESSA<";
                                    } else {
                                        component.arrProg_txt = _artifactline.requestStatusField("fermate", i, "arrivo_teorico") != null ? Utils.getTime(_artifactline.requestStatusField("fermate", i, "arrivo_teorico")) : "--";
                                        component.partProg_txt = _artifactline.requestStatusField("fermate", i, "partenza_teorica") != null ? Utils.getTime(_artifactline.requestStatusField("fermate", i, "partenza_teorica")) : "--";
                                        var arrEff = _artifactline.requestStatusField("fermate", i, "arrivoReale");
                                        if (arrEff != null)
                                            component.arrEff_txt = Utils.getTime(arrEff);
                                        else
                                            component.arrEff_txt = "--";
                                        var partEff = _artifactline.requestStatusField("fermate", i, "partenzaReale");
                                        if (partEff != null)
                                            component.partEff_txt = Utils.getTime(partEff);
                                        else
                                            component.partEff_txt = "--";
                                        var bin = _artifactline.requestStatusField("fermate", i, "binarioProgrammatoArrivoDescrizione");
                                        if (bin != null)
                                            component.bin_txt = bin.toString().trim();
                                        else
                                            component.bin_txt = "--";
                                        var or = _artifactline.requestStatusField("fermate", i, "binarioEffettivoArrivoDescrizione");
                                        if (or != null)
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
                            text: _artifactline.requestStatusField("destinazioneEstera") != null ? _artifactline.requestStatusField("destinazioneEstera") : _artifactline.requestStatusField("destinazione")
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontWeight: FontWeight.W500
                            textStyle.color: Color.Black
                            bottomMargin: ui.du(0.0)
                            topMargin: ui.du(0.0)
                        }
                        Label {
                            text: " Arrivo programmato: " + (_artifactline.requestStatusField("oraArrivoEstera") != null ? Utils.getTime(_artifactline.requestStatusField("oraArrivoEstera")) : _artifactline.requestStatusField("compOrarioArrivo"))
                            bottomMargin: ui.du(0.5)
                            textStyle.color: Color.Black
                            topMargin: ui.du(0.5)
                        }
                        Label {
                            //text: " Arrivo previsto: " + (_artifactline.requestStatusField("fermate", _artifactline.requestStatusField("nFermate")-1, "arrivoReale")!=null ? cont.Utils.getTime(_artifactline.requestStatusField("fermate", _artifactline.requestStatusField("nFermate")-1, "arrivoReale")) : "--")
                            text: " Arrivo previsto: " + (_artifactline.requestStatusField("oraArrivoEstera") != null ? Utils.getTime(_artifactline.requestStatusField("oraArrivoEstera") + _artifactline.requestStatusField("ritardo") * 60000) : (_artifactline.requestStatusField("compOrarioArrivoZeroEffettivo") != null ? _artifactline.requestStatusField("compOrarioArrivoZeroEffettivo") : "--"))
                            textStyle.color: Color.Black
                            bottomMargin: ui.du(0.0)
                            topMargin: ui.du(0.0)
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
