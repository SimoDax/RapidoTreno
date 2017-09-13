import bb.cascades 1.4
import bb.system 1.2
import Storage.LocalDataManager 1.0

NavigationPane {
    id: navigationPane
    onPopTransitionEnded: {
        if (page.objectName == "tl")
            page.cleanup();
        //  _artifactline.clearPreloaded();
        page.destroy()
    }

    Page {
        id: main
        objectName: "main"
        property string stazpart
        property string stazarr
        property string stazpartid
        property string stazarrid
        property string data
        property bool da_ready: false
        property bool a_ready: false

        property alias err: err
        property alias adulti: adulti
        property alias bambini: bambini
        property alias dtpicker: dtpicker
        property alias av: av
        property alias italo: italo
        //! [0]
        function pushPane() {
            //indicator.stop();
            wait.close();
            //wait.destroy();
            navigationPane.push(customViewPage.createObject())
        }
        function setModel() {
            l_da.dataModel = _artifactline.model;
        }
        function fillGroupDataModel() {
        }
        function errorDialog(errorMessage) {
            wait.close();
            myQmlToast.body = errorMessage;
            myQmlToast.show();
        }

        onCreationCompleted: {
            _artifactline.artifactsLoaded.connect(pushPane);
            _artifactline.badResponse.connect(errorDialog);
            _artifactline.pendToast.connect(pendSwitched.show);
            //_artifactline.stazioniLoaded.connect(setModel);
            //fillGroupDataModel();
        }

        //! [0]

        Container {
            layout: StackLayout {
            }
            //background: Color.create("#111111")
            Titolo {
                text: "RapidoTreno - Home"
            }
            ScrollView {
                id: screen
                scrollViewProperties.scrollMode: ScrollMode.Vertical
                scrollViewProperties.initialScalingMethod: ScalingMethod.None
                scrollViewProperties.pinchToZoomEnabled: false
                scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                implicitLayoutAnimationsEnabled: false
                Container {
                    Header {
                        title: "Cerca il Tuo Viaggio"
                        horizontalAlignment: HorizontalAlignment.Fill
                        minHeight: ui.du(10.0)
                    }
                    Container {
                        id: listContainer
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        topPadding: ui.du(1.0)
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        bottomPadding: ui.du(1)
                        layout: StackLayout {

                        }
                        Container {
                            id: screenInfo
                            verticalAlignment: VerticalAlignment.Top
                            topMargin: ui.du(0.0)
                            topPadding: ui.du(0.0)
                            Label {
                                id: da
                                text: "Da:"
                                topMargin: ui.du(0.0)
                                textStyle.fontSize: FontSize.Large
                                //textStyle.color: Color.create("#f0f0f0")
                            }
                            //! [1]
                            TextField {
                                id: screenName
                                objectName: "partTxt"
                                text: ""
                                hintText: "Partenza"
                                navigation.focusPolicy: NavigationFocusPolicy.NotFocusable
                                onTextChanging: {
                                    if (screenName.focused == true) {
                                        main.da_ready = false;
                                        //if(text != "")
                                        //_artifactline.caricaStazioni(screenName.text.trim());
                                        stazlist.smartLoad(screenName.text.trim());
                                        //else _artifactline.resetStazioni();
                                    }
                                }
                                onFocusedChanged: {
                                    if (focused == true) {
                                        screen.scrollViewProperties.scrollMode = ScrollMode.None
                                        l_da.visible = true;
                                        listContainer.minHeight = ui.du(80);
                                        l_da.bottomMargin = ui.du(80);
                                        //_artifactline.resetStazioni();
                                        //if(text != "")
                                        stazlist.smartLoad(screenName.text.trim());
                                    }
                                }
                            }
                            ListView {
                                id: l_da
                                dataModel: stazlist.stazioni
                                minHeight: ui.du(60.0)
                                maxHeight: ui.du(90.0)
                                visible: false
                                horizontalAlignment: HorizontalAlignment.Fill
                                topPadding: ui.du(0.0)
                                topMargin: ui.du(0.0)
                                listItemComponents: [
                                    ListItemComponent {
                                        type: "item"
                                        Container {
                                            id: itemRoot
                                            minWidth: ui.du(30)
                                            background: (itemRoot.ListItem.selected || itemRoot.ListItem.active) ? ui.palette.primarySoft : SystemDefaults.Paints.ContainerBackground
                                            //preferredWidth: ui.du(85.3) //preferredHeight: ui.du(10) //maxHeight: ui.du(15)
                                            layout: StackLayout {

                                            }
                                            preferredWidth: Infinity
                                            topPadding: ui.du(1)
                                            leftPadding: ui.du(2.0)
                                            bottomPadding: ui.du(1)
                                            Label {
                                                id: s
                                                horizontalAlignment: HorizontalAlignment.Left
                                                verticalAlignment: VerticalAlignment.Center
                                                topMargin: ui.du(0.0)
                                                bottomMargin: ui.du(0.0)
                                                text: ListItemData.name
                                                textStyle {
                                                    base: SystemDefaults.TextStyles.PrimaryText
                                                    color: (itemRoot.ListItem.selected || itemRoot.ListItem.active) ? ui.palette.secondaryTextOnPrimary : (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright ? ui.palette.textPrimary : Color.LightGray)
                                                }
                                                multiline: false
                                            }
                                        }
                                    }
                                ]
                                onTriggered: {
                                    var selectedItem = dataModel.data(indexPath);
                                    screenName.text = selectedItem.name;
                                    l_da.visible = false;
                                    main.stazpart = selectedItem.name;
                                    //main.stazpartid = selectedItem.id;
                                    main.da_ready = true;
                                    listContainer.minHeight = ui.du(0);
                                    l_da.bottomMargin = ui.du(0);
                                    screen.scrollViewProperties.scrollMode = ScrollMode.Vertical
                                    //clearSelection() //select(indexPath)
                                }

                            }
                            // <--- DESTINAZIONE --->
                            Label {
                                text: "A:"
                                topMargin: ui.du(2.0)
                                textStyle.fontSize: FontSize.Large
                                //textStyle.color: Color.create("#f0f0f0")
                            }
                            //! [1]
                            TextField {
                                id: _screenName
                                objectName: "arrTxt"
                                text: ""
                                hintText: "Arrivo"
                                navigation.focusPolicy: NavigationFocusPolicy.NotFocusable
                                onFocusedChanged: {
                                    if (_screenName.focused == true) {
                                        screen.scrollViewProperties.scrollMode = ScrollMode.None
                                        screenName.visible = false;
                                        da.visible = false;
                                        listContainer.minHeight = ui.du(80);
                                        l_a.visible = true;
                                        //_artifactline.resetStazioni();
                                        //if(text != "")
                                        stazlist.smartLoad(_screenName.text.trim());
                                    }
                                }
                                onTextChanging: {
                                    if (_screenName.focused == true) {
                                        main.a_ready = false;
                                        //if(text != "")
                                        stazlist.smartLoad(_screenName.text.trim());
                                        //else _artifactline.resetStazioni();
                                    }
                                }
                                bottomMargin: ui.du(0.0)
                            }
                            ListView {
                                id: l_a
                                dataModel: stazlist.stazioni
                                minHeight: ui.du(60.0)
                                maxHeight: ui.du(90.0)
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
                                            background: _itemRoot.ListItem.active ? ui.palette.primarySoft : SystemDefaults.Paints.ContainerBackground
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
                                                    color: (_itemRoot.ListItem.selected || _itemRoot.ListItem.active) ? ui.palette.secondaryTextOnPrimary : (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright ? ui.palette.textPrimary : Color.LightGray)
                                                }
                                                multiline: false
                                            }
                                        }
                                    }
                                ]
                                onTriggered: {
                                    var selectedItem = dataModel.data(indexPath);
                                    _screenName.text = selectedItem.name;
                                    l_a.visible = false;
                                    screenName.visible = true;
                                    da.visible = true;
                                    listContainer.minHeight = ui.du(0);
                                    main.stazarr = selectedItem.name;
                                    //main.stazarrid = selectedItem.id;
                                    main.a_ready = true; //clearSelection() //select(indexPath)
                                    screen.scrollViewProperties.scrollMode = ScrollMode.Vertical
                                }
                                //leftMargin: ui.du(5.0)
                                //leftPadding: ui.du(5.0)
                            }
                            Container {
                                topMargin: ui.du(1.5)
                                topPadding: ui.du(1.5)
                                bottomMargin: 0
                                bottomPadding: 0
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                CheckBox {
                                    id: av
                                    text: "Preferisci AV"

                                    horizontalAlignment: HorizontalAlignment.Fill
                                    bottomMargin: 0
                                    bottomPadding: 0
                                    topMargin: ui.du(1.0)
                                }
                                CheckBox {
                                    id: italo
                                    text: "Includi Italo"
                                    horizontalAlignment: HorizontalAlignment.Right
                                    bottomMargin: 0
                                    bottomPadding: 0
                                    topMargin: ui.du(1.0)
                                    leftMargin: ui.du(2.0)
                                    enabled: Application.applicationName == "RapidoTreno"
                                }
                            } //<--- FINE DESTINAZIONE --->
                        }
                    }
                    Header {
                        title: "Quando vuoi partire?"
                        horizontalAlignment: HorizontalAlignment.Fill
                        topMargin: ui.du(1.7)
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        topPadding: ui.du(2.2)
                        bottomPadding: ui.du(2.2)
                        DateTimePicker {
                            id: dtpicker
                            //value: "2016-08-09T07:35:00"
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            mode: DateTimePickerMode.DateTime
                            bottomMargin: ui.du(0.0)
                            kind: PickerKind.List
                        }
                    }
                    Header {
                        title: "Passeggeri (max 5)"
                    }
                    Container {
                        preferredWidth: Infinity
                        leftPadding: ui.du(2.2)
                        rightPadding: ui.du(2.2)
                        bottomMargin: ui.du(2.2)
                        horizontalAlignment: HorizontalAlignment.Fill
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        bottomPadding: ui.du(2.2)
                        topPadding: ui.du(2.2)
                        DropDown {
                            id: adulti
                            title: "Adulti"
                            horizontalAlignment: HorizontalAlignment.Left
                            Option {
                                text: "0"
                                value: "0"
                            }
                            Option {
                                text: "1"
                                value: "1"
                                selected: true
                            }
                            Option {
                                text: "2"
                                value: "2"
                            }
                            Option {
                                text: "3"
                                value: "3"
                            }
                            Option {
                                text: "4"
                                value: "4"
                            }
                            Option {
                                text: "5"
                                value: "5"
                            }
                        }
                        DropDown {
                            id: bambini
                            title: "Bambini"
                            horizontalAlignment: HorizontalAlignment.Right
                            Option {
                                text: "0"
                                value: "0"
                                selected: true
                            }
                            Option {
                                text: "1"
                                value: "1"
                            }
                            Option {
                                text: "2"
                                value: "2"
                            }
                            Option {
                                text: "3"
                                value: "3"
                            }
                            Option {
                                text: "4"
                                value: "4"
                            }
                            Option {
                                text: "5"
                                value: "5"
                            }
                        }
                    }
                    Label {
                        function getdate() {
                            var x = dtpicker.value.getDate() + "-" + (dtpicker.value.getMonth() + 1) + "-" + dtpicker.value.getFullYear() + "T" + tmpicker.value.getHours() + ":";
                            if (tmpicker.value.getMinutes() < 10)
                                x += "0" + tmpicker.value.getMinutes();
                            else
                                x += tmpicker.value.getMinutes();
                            return x;
                        }
                        id: err
                        verticalAlignment: VerticalAlignment.Center
                        visible: false
                        multiline: true
                        //text: _artifactline.errorMessage
                        text: dtpicker.value
                        topMargin: ui.du(0.0)
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Gray
                        }
                    } //! [2]
                }
            }
        }
        //! [4]
        attachedObjects: [
            LocalDataManager {
                id: stazlist
            },
            ComponentDefinition {
                id: customViewPage
                source: "CustomTimelineView.qml"
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
            },
            SystemToast {
                id: pendSwitched
                body: _artifactline.pend ? "La modalità pendolare è ora attiva" : "La modalità pendolare è stata disattivata"
            }
        ]
        //! [4]
        actions: [
            ActionItem {
                id: cerca
                title: "Cerca"
                ActionBar.placement: ActionBarPlacement.Signature
                enabled: main.da_ready && main.a_ready && ! _artifactline.active && (parseInt(adulti.selectedOption.text) + parseInt(bambini.selectedOption.text)) > 0 && main.stazpart != main.stazarr
                imageSource: "asset:///images/ic_search.png"

                function getdate() {
                    var x = dtpicker.value.getDate() + "/" + (dtpicker.value.getMonth() + 1) + "/" + dtpicker.value.getFullYear() + " " + dtpicker.value.getHours() + ":";
                    if (dtpicker.value.getMinutes() < 10)
                        x += "0" + dtpicker.value.getMinutes();
                    else
                        x += dtpicker.value.getMinutes();
                    return x;
                }

                onTriggered: {
                    wait.open();
                    main.data = getdate();
                    _artifactline.requestArtifact(main.stazpart, main.stazarr, err.text, adulti.selectedOption.text, bambini.selectedOption.text, av.checked ? "true" : "false", italo.checked, false);
                    stazlist.save(main.stazpart, main.stazarr);

                }

                attachedObjects: ComponentDefinition {
                    id: pageDefinition
                    source: "CustomTimelineView.qml"
                }
            },
            ActionItem {
                id: pend
                title: "Pendolare"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: _artifactline.pend ? true : main.da_ready && main.a_ready
                imageSource: _artifactline.pend ? "asset:///images/swap_v_baseGreen.amd" : "asset:///images/swap_v_baseRed.amd"
                onTriggered: {
                    _artifactline.switchPend(main.stazpart, main.stazarr);
                }
            },
            ActionItem {
                id: scambia
                title: "Scambia stazioni"
                ActionBar.placement: ActionBarPlacement.OnBar
                enabled: cerca.enabled
                imageSource: "asset:///images/swap_icon.amd"
                onTriggered: {
                    var appo = main.stazpart;
                    main.stazpart = main.stazarr;
                    main.stazarr = appo;
                    appo = screenName.text;
                    screenName.text = _screenName.text;
                    _screenName.text = appo;
                    stazlist.reset();
                }
            }
        ]
    }

}