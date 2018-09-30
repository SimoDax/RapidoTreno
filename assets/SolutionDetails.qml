import bb.cascades 1.4

Page {
    property string searchedTrain
    property bool offersRequested: false
    
    onCreationCompleted: {
        _artifactline.statusDataLoaded.connect(pushPane)
    }

    function pushPane() {
        wait.close();
        if ((parseInt(searchedTrain) > 9900 && parseInt(searchedTrain) < 9999) || (parseInt(searchedTrain) > 8900 && parseInt(searchedTrain) < 8999)){
            var page = statoTrenoPageItalo.createObject()
            navigationPane.push(page)
        }
        else{
            var page = statoTrenoPage.createObject()
            navigationPane.push(page)
        }
        page.numeroTreno = searchedTrain    //save it for the refresh button
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
                    if (tl.dati.saleable)
                        "Prezzo a partire da: " + parseFloat(tl.dati.minprice).toFixed(2) + "€";
                    else
                        "Soluzione non acquistabile"
                }
                //textStyle.color: Color.create(primaryWhite)
                textStyle.fontSize: FontSize.Medium
                topMargin: ui.du(0.0)

            }
        }
        //-----------------------------------------
        // color palette test section
        /*Container {
         * minHeight: ui.du(50)
         * layout: DockLayout {}
         * Container {
         * verticalAlignment: VerticalAlignment.Center
         * horizontalAlignment: HorizontalAlignment.Center
         * Container {
         * background: ui.palette.primary
         * Label {
         * text: "Primary Dark" + Color.toHexString(ui.palette.primaryDark).toUpperCase();
         * }
         * }
         * Container {
         * background: ui.palette.primaryBase
         * Label {
         * text: "Primary Base " + Color.toHexString(ui.palette.se).toUpperCase();
         * }
         * }
         * Container {
         * background: ui.palette.primarySoft
         * Label {
         * text: "Primary Soft " + Color.toHexString(ui.palette.primarySoft).toUpperCase();
         * }
         * }
         * Container {
         * background: ui.palette.background
         * Label {
         * text: "Background " + Color.toHexString(ui.palette.background).toUpperCase();
         * }
         * }
         * Container {
         * background: ui.palette.plain
         * Label {
         * text: "Plain " + Color.toHexString(ui.palette.plain).toUpperCase();
         * }
         * }
         * Container {
         * background: ui.palette.plainBase
         * Label {
         * text: "Plain Base" + Color.toHexString(ui.palette.plainBase).toUpperCase();
         * }
         * }
         * }
         }*/

        //-----------------------------------------
        ListView {
            id: lista
            dataModel: _artifactline.solutionDetails
            
            onTriggered: {
                var num = dataModel.data(indexPath).trainidentifier.match(/\d+$/)[0].trim()
                searchedTrain = num
                
                if (parseInt(num) > 9900 && parseInt(num) < 9999)
                    _artifactline.requestStatusDataItalo(num)
                else
                    _artifactline.requestStatusData(num)
                
                wait.open();

            }

            function conn(seg) {
                _artifactline.offersLoaded.connect(seg.init)
                if(!offersRequested){
                    offersRequested = true;
                    
                    if (tl.dati.idsolution) { //no offers for italo (sorry montezemolo)
                        _artifactline.requestOffers(tl.dati.idsolution, false)
                    } else {				  //jk we have offers too now (screw you montezemolo)
                        _artifactline.requestOffers(tl.dati.numeroTreno, false)
                    }
                }
            }
            function getTrainList() {
                return _artifactline.trainsDetails
            }
            
            listItemComponents: [

                ListItemComponent {
                    type: "item"
                    
                    Container {
                        
                        id: itemRoot
                        preferredWidth: Infinity
                        //preferredHeight: ui.ddu(20.5)
                        //minHeight : ui.du(25)
                        //pref height du 18
                        //maxHeight: ui.du(18)
                        //verticalAlignment: VerticalAlignment.Center

                        background: bg.imagePaint

                        attachedObjects: [
                            ImagePaintDefinition {
                                id: bg
                                repeatPattern: RepeatPattern.X
                                imageSource: "asset:///images/bg.png"
                            }
                        ]
                        Container {
                            //verticalAlignment: VerticalAlignment.Center
                            layout: DockLayout {

                            }

                            Container {
                            //max height du 18
                            //preferredHeight: ui.ddu(20.5) * 2
                            //verticalAlignment: VerticalAlignment.Fill
                            horizontalAlignment: HorizontalAlignment.Left
                            leftPadding: ui.du(2.2)
                            rightPadding: ui.du(2.2)
                            layout: StackLayout {
                                orientation: LayoutOrientation.TopToBottom
                            }

                                Label {
                                id: orarioPartenza
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                function getOrarioPartenza() {
                                    var d = new Date(ListItemData.departuretime);
                                    var min = d.getMinutes().toString();
                                    if (min < 10)
                                        min = "0" + min;
                                    return d.getHours() + ":" + min + " " + ListItemData.departurestation.toUpperCase();
                                }
                                text: getOrarioPartenza()
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
                                    text: {
                                        "" + ListItemData.trainacronym + " " + ListItemData.trainidentifier.replace(/\s+/g, " ");
                                    }
                                    textStyle {
                                        base: SystemDefaults.TextStyles.SmallText
                                        color: Color.DarkGray
                                        fontSize: FontSize.Small
                                    }
                                    multiline: true
                                    textFit.minFontSizeValue: 6.0
                                    //verticalAlignment: VerticalAlignment.Fill
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
                                //verticalAlignment: VerticalAlignment.Fill
                                horizontalAlignment: HorizontalAlignment.Fill
                                topMargin: ui.du(0.0)
                                bottomMargin: ui.du(0.0)
                                leftMargin: ui.du(2.0)
                            }

                            Label {
                                function getOrarioArrivo() {
                                    var d = new Date(ListItemData.arrivaltime);
                                    var min = d.getMinutes().toString();
                                    if (min < 10)
                                        min = "0" + min;
                                    return d.getHours() + ":" + min + " " + ListItemData.arrivalstation.toUpperCase();
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
                            SegmentedControl {
                                id: seg
                                
                                function init() {
                                    var trainList = itemRoot.ListItem.view.getTrainList()
                                    var indexPath = itemRoot.ListItem.indexPath
                                    var servicelist = trainList[indexPath].servicelist 

                                    for (var i = 0; i < servicelist.length; i++) {    //create tab headers for the services
                                        //console.debug("name:" + _artifactline.trainList)
                                        var tab = option.createObject()
                                        tab.text = servicelist[i].name
                                        tab.description = servicelist[i].name
                                        seg.add(tab)
                                    }
                                }
                                
                                function initSub(i){
                                    var trainList = itemRoot.ListItem.view.getTrainList()
                                    var indexPath = itemRoot.ListItem.indexPath
                                    var subservicelist = trainList[indexPath].servicelist[i].subservicelist
                                    
                                    for (var j = 0; j < subservicelist.length; j++) {    //create tab headers for the subservices
                                        var tab  = option.createObject()
                                        tab.text = subservicelist[j].name
                                        tab.description = subservicelist[j].name
                                        subSeg.add(tab)
                                    }
                                }

                                function displayServiceClass(i) {
                                    var trainList = itemRoot.ListItem.view.getTrainList()
                                    var indexPath = itemRoot.ListItem.indexPath
                                    console.debug(i)
                                    var sub = trainList[indexPath].servicelist[i].subservicelist
                                    if(sub != null && sub.length != null && sub.length > 0){    //subservice segmented control needed
                                        
                                        subSeg.visible = true
                                        subSeg.removeAll()
                                        initSub(i);
                                        //once initialized it will fire a index changed event on the first element,
                                        //calling displaySubServiceClass autonomously
                                        
                                    }
                                    else{
                                        subSeg.visible = false
                                        showOffersList(trainList[indexPath].servicelist[i].offerlist)
                                    }
                                }
                                
                                function displaySubServiceClass(j){
                                    var trainList = itemRoot.ListItem.view.getTrainList()
                                    var indexPath = itemRoot.ListItem.indexPath
                                    showOffersList(trainList[indexPath].servicelist[seg.selectedIndex].subservicelist[j].offerlist)
                                }
                                
                                function showOffersList(offerlist){
                                    for (var j = 0; j < offerlist.length; j++) {
                                        //x.size = _artifactline.servicelist[i].offerlist.size();
                                        var offer = offerlist[j]
                                        if (offer.saleable) {
                                            var y = offerItem.createObject();
                                            y.name = offer.name
                                            y.price = parseFloat(offer.price).toFixed(2) + " €"
                                            
                                            //y.desc = offer.message
                                            if(offer.available < 10000)    //dummy threshold to filter trains without counted seats
                                                if(offer.available == -1)
                                                    y.descVisible = false
                                                else if(offer.available == 0)
                                                    y.desc = "Posti esauriti"
                                                else if(offer.available == 1)
                                                    y.desc = offer.available + " posto rimasto"
                                                else
                                                    y.desc = offer.available + " posti rimasti"
                                            else
                                                y.desc = "Posti a sedere senza prenotazione"
                                                
                                            offersCont.add(y)
                                        }
                                    }
                                }

                                onCreationCompleted: {
                                    itemRoot.ListItem.view.conn(seg)
                                }

                                onSelectedIndexChanged: {
                                    offersCont.removeAll()
                                    displayServiceClass(selectedIndex)
                                }
                                attachedObjects: [
                                    ComponentDefinition {
                                        id: offerItem
                                        Container {
                                            //minHeight: ui.du(40)
                                            property alias name: name.text
                                            property alias price: price.text
                                            property alias desc: desc.text
                                            property alias descVisible: desc.visible
                                            layout: StackLayout {

                                            }
                                            //verticalAlignment: VerticalAlignment.Fill
                                            topMargin: ui.du(1.0)
                                            //bottomMargin: ui.du(1.0)
                                            leftPadding: ui.du(1.0)
                                            rightPadding: ui.du(1.0)
                                            Container {
                                                verticalAlignment: VerticalAlignment.Top
                                                layout: StackLayout {
                                                    orientation: LayoutOrientation.LeftToRight

                                                }
                                                Label {
                                                    id: price
                                                    textStyle.fontWeight: FontWeight.Bold
                                                    textStyle.fontSize: FontSize.Medium
                                                    textStyle.color: Color.Black
                                                    horizontalAlignment: HorizontalAlignment.Right
                                                }
                                                Label {
                                                    id: name
                                                    textStyle.color: Color.Black
                                                    //textStyle.fontSize: FontSize.Medium
                                                    textStyle.base: SystemDefaults.TextStyles.BodyText
                                                    horizontalAlignment: HorizontalAlignment.Left
                                                }
                                                
                                            }

                                            Label {
                                                id: desc
                                                textStyle.color: Color.Black
                                                textStyle.fontSize: FontSize.Small
                                                multiline: true
                                                autoSize.maxLineCount: 3
                                                //verticalAlignment: VerticalAlignment.Fill
                                                horizontalAlignment: HorizontalAlignment.Fill
                                                //editable: false
                                                //focusHighlightEnabled: false
                                                //backgroundVisible: false
                                                topMargin: ui.du(0.0)
                                                rightMargin: ui.du(0.0)
                                                leftMargin: ui.du(0.0)
                                                bottomMargin: ui.du(0.0)
                                            }

                                            Divider {
                                                verticalAlignment: VerticalAlignment.Bottom
                                            }
                                        }
                                    },
                                    ComponentDefinition {
                                        id: option
                                        Option {

                                        }
                                    }
                                ]
                            }
                            SegmentedControl {
                                id: subSeg
                                visible: false
                                onSelectedIndexChanged: {
                                    if(selectedIndex != -1){    //-1: all options removed
                                        console.debug('subSeg index: ' + selectedIndex)
                                        offersCont.removeAll()
                                        seg.displaySubServiceClass(selectedIndex)
                                    }

                                }
                            }
                            Container {
                                id: offersCont
                                //verticalAlignment: VerticalAlignment.Fill
                                bottomPadding: 0
                                
                            }
                        }
}
                    }

                }
            ]
        }
        /*Header {
         * title: "Opzioni d'acquisto:"
         }*/

    }

    actions: [
        InvokeActionItem {
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
                data: "Partenza alle " + tl.dati.orarioPartenza + " da " + tl.dati.origin + "\nTreno " + tl.dati.numeroTreno.toString().replace(",", " / ") + "\nArrivo alle " + tl.dati.orarioArrivo + " a " + tl.dati.destination + (tl.dati.saleable ? "\nCosto minimo: " + parseFloat(tl.dati.minprice).toFixed(2) + " Euro" : "\nNon acquistabile")
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
                _artifactline.pagah(tl.index, main.adulti.selectedOption.text, main.bambini.selectedOption.text)
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
