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
import bb.system 1.2

TabbedPane {
    id: tabbedPane
    showTabsOnActionBar: false

    function fromStationToTrain(num) {
        activeTab = statoTreno;
        var nav = statoDelegate.object;
        nav.triggerSearch(num);
    }

    Tab {
        title: "Cerca soluzione"
        imageSource: "asset:///images/train_icon.png"
        delegate: Delegate {
            id: ricercaDelegate
            source: "asset:///Ricerca.qml"
        }
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
    } //end tab

    Tab {
        id: statoTreno
        title: "Stato treno"
        imageSource: "asset:///images/stato_treno.amd"
        delegate: Delegate {
            id: statoDelegate
            source: "asset:///StatoTrenoRicerca.qml"
        }
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
    }
    Tab {
        title: "Tabellone partenze"
        imageSource: "asset:///images/stato_treno.amd"
        delegate: Delegate {
            id: stazDelegate
            source: "asset:///StazioneRicerca.qml"
        }
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
    }
    Tab {
        title: "Area Personale"
        imageSource: "asset:///images/user.png"
        delegate: Delegate {
            id: profileDelegate
            source: "asset:///Login.qml"
        }
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected

    }
    Tab {
        title: "Infomobilità"
        imageSource: "asset:///images/globe.png"
        delegate: Delegate {
            id: newsDelegate
            source: "asset:///fsnews.qml"
        }
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
    }

    Menu.definition: MenuDefinition {
        actions: [
            ActionItem {
                title: "Info"
                imageSource: "asset:///images/ic_info.png"
                attachedObjects: [
                    SystemDialog {
                        id: info
                        body: {
                            if (Application.applicationName == "RapidoTreno Free")
                                Application.applicationName + " " + Application.applicationVersion + "\n\nSe l'app ti soddisfa per favore considera l'acquisto della versione a pagamento per supportare lo sviluppatore e ottenere il supporto per italo :)\n\nUna copia del codice sorgente di quest'app è pubblicamente consultabile su https://github.com/SimoDax/RapidoTreno";
                            else
                                Application.applicationName + " " + Application.applicationVersion + "\n\nGrazie per aver scelto di supportare lo sviluppatore :)\n\nPer segnalare bug scrivere a: mailto:s.dassi.pub@gmail.com con oggetto [RAPIDOTRENO]<descrizione bug>\n\nUna copia del codice sorgente di quest'app è pubblicamente consultabile su https://github.com/SimoDax/RapidoTreno"
                        }
                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection && Application.applicationName == "RapidoTreno Free")
                                _invoke.trigger("bb.action.OPEN")
                        }
                    },
                    Invocation {
                        id: _invoke
                        query {
                            uri: "appworld://content/59998701"
                            invokeTargetId: "sys.appworld"
                        }
                    }
                ]
                onTriggered: {
                    info.exec();
                }
            },
            ActionItem {
                title: "Dona"
                imageSource: "asset:///images/coins.png"
                onTriggered: {
                    _pay.trigger("bb.action.OPEN")
                }
                attachedObjects: Invocation {
                    id: _pay
                    query {
                        uri: "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ELABEXREWYGRY"
                        invokeTargetId: "sys.browser"
                    }
                }
            },
            ActionItem {
                title: "Cambia tema"
                onTriggered: {
                    if (Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright) {
                        Application.themeSupport.setVisualStyle(VisualStyle.Dark);
                        _artifactline.saveSetting("style", 2);
                    } else {
                        Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                        _artifactline.saveSetting("style", 1);
                    }
                }
            }
        ]
    }
} //end tabbedPane
