import bb.cascades 1.4
import bb.system 1.2
import Storage.LocalDataManager 1.0

Page {
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    id: login
    onCreationCompleted: {
        _artifactline.profileLoaded.connect(chiudi);
        _artifactline.badResponse.connect(errorDialog);
        if (_artifactline.loggedIn) {
            wait.open();
            _artifactline.requestAreaPers("", "");
        } else {
            save.checked = _artifactline.loadSetting("rememberMe");
            //load saved credentials
            var cred = localDataManager.decryptCredentials();
            user.text = cred.user;
            pass.text = cred.pass;
        }
    }
    
    function showAreaPers() {
        var areaPers = areaPersonale.createObject();
        main.removeAll();
        login.removeAllActions();
        main.add(areaPers);
    }

    function chiudi() {
        showAreaPers();
        wait.close();
    }

    function errorDialog(errorMessage) {
        wait.close();
        myQmlToast.body = errorMessage;
        myQmlToast.show();
    }

    Container {
        id: main

        Titolo {
            text: "Login Area Personale"
        }

        Container {

            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            topPadding: ui.du(2.0)
            leftPadding: ui.du(2.2)
            rightPadding: ui.du(2.2)
            bottomPadding: ui.du(1)
            Label {
                text: "Username:"
                textStyle.fontSize: FontSize.Large
            }
            TextField {
                id: user
                hintText: "Username"
            }
            Label {
                text: "Password:"
                textStyle.fontSize: FontSize.Large
                topMargin: ui.du(3.0)
            }
            TextField {
                id: pass
                hintText: "Password"
                inputMode: TextFieldInputMode.Password
            }

            CheckBox {
                id: save
                text: "Ricordami"
                topMargin: ui.du(4.0)

            }
        }
        attachedObjects: [
            ComponentDefinition {
                id: areaPersonale
                source: "asset:///AreaPersonale.qml"
            },
            Wait {
                id: wait
            },
            SystemToast {
                id: myQmlToast
                body: "Errore nell'elaborazione della richiesta"
            },
            LocalDataManager {
                id: localDataManager
            }
        ]

    }
    actions: [
        ActionItem {
            id: loginBtn
            title: "Login"
            ActionBar.placement: ActionBarPlacement.Signature
            enabled: user.text != "" && user.text != ""
            imageSource: "asset:///images/login_round.png"
            onTriggered: {
                wait.open();
                if (save.checked)
                    localDataManager.encryptCredentials(user.text, pass.text);
                else
                    localDataManager.deleteCredentials();
                _artifactline.saveSetting("rememberMe", save.checked);
                _artifactline.requestAreaPers(user.text, pass.text);
            }
        }
    ]
}