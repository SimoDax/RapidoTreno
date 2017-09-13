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

import bb.cascades 1.3

Page {
    id: tl
    property variant dati
    
    Container {
        layout: StackLayout {

        }

        Container {
            id: topbar
            minHeight: ui.du(14.0)
            maxHeight: ui.du(14.0)
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                id: titolo
                minHeight: ui.du(9.5)
                maxHeight: ui.du(9.5)
                background: redgrad.imagePaint
                horizontalAlignment: HorizontalAlignment.Fill
                attachedObjects: [
                    ImagePaintDefinition {
                        id: redgrad
                        repeatPattern: RepeatPattern.X
                        imageSource: "asset:///images/redgrad.png"
                    }
                ]
                Container{
                    topPadding: ui.du(2.0)
                    leftPadding: ui.du(2.2)
                    rightPadding: ui.du(2.2)
                    bottomPadding: ui.du(2.2)
                    verticalAlignment: VerticalAlignment.Top
                    horizontalAlignment: HorizontalAlignment.Left
                    Label {
                        text: "Soluzioni di viaggio"
                        textStyle.color: Color.White
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Fill
                        textStyle.fontSize: FontSize.Large
                        textStyle.fontWeight: FontWeight.W500
                        textStyle.fontSizeValue: 0.0
                        textStyle.textAlign: TextAlign.Default
                        textFit.mode: LabelTextFitMode.Default
                    }
            }

            }
            Container {
                id: ricerca
                minHeight: ui.du(8)
                maxHeight: ui.du(8)
                background: Color.create("#006263")
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: ui.du(2.2)
                rightPadding: ui.du(2.2)
                topPadding: ui.du(.2)
                bottomPadding: ui.du(.5)
                Label {
                    text: main.stazpart + " >> " + main.stazarr + " " + main.data
                    //textFit.mode: LabelTextFitMode.FitToBounds
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.color: Color.White
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
                        preferredHeight: ui.du(18)
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

                        /*ImageView {
                         * horizontalAlignment: HorizontalAlignment.Fill
                         * verticalAlignment: VerticalAlignment.Fill
                         * 
                         * imageSource: itemRoot.ListItem.selected ? "asset:///images/item_background_selected.png" :
                         * "asset:///images/item_background.png"
                         }*/

                        Container {
                            maxHeight: ui.du(18)
                            horizontalAlignment: HorizontalAlignment.Left
                            leftPadding: ui.du(2.2)
                            rightPadding: ui.du(2.2)
                            layout: StackLayout {
                                orientation: LayoutOrientation.TopToBottom
                            }
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 5.0
                            }

                            Label {
                                id: orarioPartenza
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Top
                                
                                function getOrarioPartenza(){
                                if(ListItemData.size == 1)
                                    return ListItemData.orarioPartenza + " " + ListItemData.origine.toUpperCase();
                                else{
                                    var x = ListItemData.orarioPartenza;
                                    var arr = x.split(",");
                                    x = ListItemData.origine;
                                    var arr_ = x.split(",");
                                    return arr[0].toUpperCase() + " " + arr_[0].toUpperCase();
                                    }
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

                            Label {
                                function getTreno(){
                                    if(ListItemData.size == 1)
                                        return ( " " + (ListItemData.categoriaDescrizione!=null ? ListItemData.categoriaDescrizione : "Treno ") + ListItemData.numeroTreno);
                                    else{
                                        var x = ListItemData.categoriaDescrizione;
                                        var arr = x.split(",");
                                        x = ListItemData.numeroTreno;
                                        var arr_ = x.split(",");
                                        var str = " " + arr[0] + " " + arr_[0];
                                        for(var i=1; i<arr.length; i++){
                                            str += " -> " + arr[i] + " " + arr_[i];
                                            }
                                        return str;
                                        }
                                }
                                id: treno
                                text: getTreno();
                                textStyle {
                                    base: SystemDefaults.TextStyles.SmallText
                                    color: Color.DarkGray
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
                                textFit.mode: LabelTextFitMode.Standard
                            }
                            Label {
                                id: durata
                                text: " Durata: " + ListItemData.durata + "\t\tCambi: " + (parseInt(ListItemData.size, 10) -1)
                                textStyle {
                                    base: SystemDefaults.TextStyles.SmallText
                                    color: Color.DarkGray
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
                                function getOrarioArrivo(){
                                    if(ListItemData.size == 1)
                                        return ListItemData.orarioArrivo + " " + ListItemData.destinazione.toUpperCase();
                                    else{
                                        var x = ListItemData.orarioArrivo;
                                    var arr = x.split(",");
                                    x = ListItemData.destinazione;
                                    var arr_ = x.split(",");
                                    return arr[arr.length -1] + " " + arr_[arr_.length -1].toUpperCase();
                                    }
                                }
                                
                                id: orarioArrivo
                                text: getOrarioArrivo();
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
                clearSelection();
                select(indexPath);
                tl.dati = dataModel.data(indexPath)
                pushPane();
            }
        }
        //! [0]
    }
    attachedObjects: [
        ComponentDefinition {
            id: detailsPage
            source: "SolutionDetails.qml"
        }
    ]
    function pushPane() {
        navigationPane.push(detailsPage.createObject());
    }
}
