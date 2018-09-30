/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import bb.cascades 1.4
import "utils.js" as Utils

Page {
    id: tl
    objectName: "tl"
    property variant dati
    property variant index
    
    function displayWait(){
        wait.open();
    }
    
    function cleanup(){
        _artifactline.removeWait.disconnect(closewait);
        _artifactline.badResponse.disconnect(closewait);
    }
    
    function closewait(){
        wait.close();
        //_artifactline.startAsyncLoad();
    }
    
    function getdate(){
        var x = main.dtpicker.value.getDate()+"/"+(main.dtpicker.value.getMonth()+1)+"/"+main.dtpicker.value.getFullYear()+"  "+(main.dtpicker.value.getHours()+offset)+":";
        if (main.dtpicker.value.getMinutes() < 10)
            x += "0" + main.dtpicker.value.getMinutes();
        else 
            x += main.dtpicker.value.getMinutes();
        return x;
    }
    
    onCreationCompleted: {
        //tl.destroyed.connect(_artifactline.clearPreloaded);
        //_artifactline.displayWait.connect(wait.open);
        _artifactline.removeWait.connect(closewait);
        _artifactline.showDetails.connect(pushPane);
        //_artifactline.startAsyncLoad();
        _artifactline.badResponse.connect(closewait);
    }
    
    
    
    Container {
        layout: StackLayout {

        }
        Container {
            id: topbar
            //minHeight: ui.ddu(16.0)
            //maxHeight: ui.ddu(16.0)
            // min e max height 14 du
            horizontalAlignment: HorizontalAlignment.Fill
            Titolo {
                text: "Soluzioni di viaggio"
            }
            Container {
                id: ricerca
                minHeight: ui.ddu(5)
                maxHeight: ui.ddu(5)
                //min e max height 8
                background: Color.create("#006263")
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(2.2)

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                //rightPadding: ui.du(2.2)
                //topPadding: ui.du(.2)
                //bottomPadding: ui.du(.5)
                Label {
                    text: main.stazpart + " >> " + main.stazarr;
                    //textFit.mode: LabelTextFitMode.FitToBounds
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.color: Color.White
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.9
                    }
                }
                Label {
                    horizontalAlignment: HorizontalAlignment.Right
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.1
                    }
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.color: Color.White
                    text: Utils.getDateFromPicker(main.dtpicker)
                    textStyle.textAlign: TextAlign.Right

                }
            }

        }

        //! [0]
        ListView {
            id: lista
            objectName: "lista"
            dataModel: _artifactline.model

            function date(timestamp) {
                return _artifactline.dateFromTimestamp(timestamp)
            }

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
                             layout: StackLayout {
                                 orientation: LayoutOrientation.TopToBottom
                             }
                             layoutProperties: StackLayoutProperties {
                                 spaceQuota: 1
                             }
                            //verticalAlignment: VerticalAlignment.Fill
                            
                            //horizontalAlignment: HorizontalAlignment.Fill
                            Container {
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                Label {
                                    text: " "
                                }
                            }
                            Container {
                                layout: StackLayout {
                                    
                                }
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            ImageView {
                                
                                 imageSource: "asset:///images/cart.amd"
                                preferredHeight: ui.du(6.0)
                                preferredWidth: ui.du(6.0)
                                //scalingMethod: ScalingMethod.Fill
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center 
                                filterColor: ListItemData.saleable ? Color.create("#006263") : Color.create("#FF0000")
                            }}
                            Container {
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                                horizontalAlignment: HorizontalAlignment.Fill
                            Label {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Bottom
                                textStyle {
                                    base: SystemDefaults.TextStyles.SmallText
                                    color: Color.DarkGray
                                    fontSize: FontSize.XSmall
                                }
                                multiline: true
                                text:{if(ListItemData.saleable)
                                        "da " + parseFloat(ListItemData.minprice).toFixed(2) + "€"
                                        }
                                topMargin: ui.du(0.0)
                                bottomMargin: ui.du(0.0)
                            }
                        }
                         }
                         
                        Container {
                            //max height du 18
                            preferredHeight: ui.ddu(20.5)
                            horizontalAlignment: HorizontalAlignment.Left
                            //leftPadding: ui.du(2.2)
                            rightPadding: ui.du(2.2)
                            layout: StackLayout {
                                orientation: LayoutOrientation.TopToBottom
                            }
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 4.0
                            }

                            Label {
                                id: orarioPartenza
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                
                                text: ListItemData.orarioPartenza + " " + ListItemData.origin.toUpperCase();
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
                                 function getTreno(){
                                     if(ListItemData.changesno == 0)
                                         return ( "" + ListItemData.numeroTreno);    //"  "
                                     else{
                                         var x = ListItemData.categoriaDescrizione;
                                         //var arr = x.split(",");
                                         x = ListItemData.numeroTreno;
                                         var arr_ = x.split(",");
                                         //var str = "  " + (arr[0] != "" ? arr[0] : "Treno") + " " + arr_[0];
                                         var str = "" + arr_[0];
                                         for(var i=1; i<arr_.length; i++){
                                             str += " -> " + arr_[i];
                                             }
                                         return str;
                                         }
                                 }
                                 id: treno
                                 text: getTreno();
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
                                text: "  Durata: " + ListItemData.duration + "        Cambi: " + ListItemData.changesno;
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
                            }

                            Label {
                                
                                id: orarioArrivo
                                text: ListItemData.orarioArrivo + " " + ListItemData.destination.toUpperCase();
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
                        Container {
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1.0
                            }
                            verticalAlignment: VerticalAlignment.Center
                            ImageView {
                                imageSource: "asset:///images/ic_next.amd"
                                filterColor: Color.create("#006263")
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Center
                            }
                        }
                    }
                }
            ]

            onTriggered: {
                clearSelection()
                select(indexPath)
                tl.dati = dataModel.data(indexPath)
                tl.index = indexPath;
                _artifactline.setSolutionDetailsModel(indexPath)
                //pushPane();        GUAI A TE CHRISTIANAIRTE, CHRISTIANAIRTE GUAI A TE
            }
        }
    }
    actions: [
        ActionItem {
            id: indietro
            title: "Indietro"
            ActionBar.placement: ActionBarPlacement.OnBar
            //enabled: _artifactline.getOffset() <= 23
            imageSource: "asset:///images/ic_reply.png"
            enabled: {
                var d = Utils.parseIsoDatetime(main.err.text);
                return d.getHours() > 0 && !wait.opened;
            }
            onTriggered: {
                var d = Utils.parseIsoDatetime(main.err.text);
                d.setHours(d.getHours()-1);
                main.dtpicker.value = d
                _artifactline.requestArtifact(main.stazpart, main.stazarr, main.err.text, main.adulti.selectedOption.text, main.bambini.selectedOption.text, av.checked?"true":"false", main.italo.checked, true);
                wait.open();
            }
        },
        ActionItem {
            id: avanti
            title: "Avanti"
            ActionBar.placement: ActionBarPlacement.OnBar
            //enabled: main.da_ready && main.a_ready && ! _artifactline.active && (parseInt(adulti.selectedOption.text)+parseInt(bambini.selectedOption.text)) > 0 && main.stazpart!=main.stazarr
            //enabled: _artifactline.getOffset() <= 23
            enabled: {
                var d = Utils.parseIsoDatetime(main.err.text);
                return d.getHours() < 23 && !wait.opened;
            }
            imageSource: "asset:///images/ic_forward.png"
            onTriggered: {
                var d = Utils.parseIsoDatetime(main.err.text);
                d.setHours(d.getHours()+1);
                main.dtpicker.value = d
                _artifactline.requestArtifact(main.stazpart, main.stazarr, main.err.text, main.adulti.selectedOption.text, main.bambini.selectedOption.text, av.checked?"true":"false", main.italo.checked, true);
                //_artifactline.requestArtifact(main.stazpart, main.stazarr, d.toISOString(), main.adulti.selectedOption.text, main.bambini.selectedOption.text, av.checked ? "true" : "false", main.italo.checked, true);
                wait.open();
            }
        }
        
    ]
    attachedObjects: [
        ComponentDefinition {
            id: detailsPage
            source: "SolutionDetails.qml"
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
        }
    ]
    function pushPane() {
        navigationPane.push(detailsPage.createObject());
    }
}
