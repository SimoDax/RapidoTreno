/*
 * StationListManager.cpp
 *
 *  Created on: 16/apr/2017
 *      Author: Simone
 */

#include <src/LocalDataManager.hpp>
#include <src/simplecrypt.h>

#include <QtCore/QObject>
#include <bb/data/JsonDataAccess>
#include <QtLocationSubset/QGeoPositionInfoSource>
#include <cmath>
#include <bb/location/PositionErrorCode>
#include <bb/system/SystemDialog>
#include <bb/system/SystemListDialog>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeTargetReply>

using namespace bb::data;
using namespace bb::location;
using namespace bb::system;
using namespace QtMobilitySubset;

#define MAX_NEAREST_STATIONS 5
#define ENCRYPTION_KEY Q_UINT64_C(0x0)	//eh, volevi..

const QString LocalDataManager::m_dumpStazioniPath = "./data/dump_2_6.json";
const QString LocalDataManager::m_dumpViaggiatrenoPath = "./app/native/assets/dump_coordinate.json";
const QString LocalDataManager::m_dumpCodiciPath = "./app/native/assets/dump_codici.json";
const QString LocalDataManager::m_credentialsPath = "./data/credentials.dat";

//  THIS CLASS SHOULD *NOT* DESTROY HERSELF

bool lessThan(const QVariantMap &i, const QVariantMap &j)
{
    return i["distance"].toDouble() < j["distance"].toDouble();
}

LocalDataManager::LocalDataManager(QObject *parent) :
        QObject(parent)
{
    m_stazioni = new GroupDataModel(QStringList() << "lastSelected" << "nameOrd", this);
    m_stazioni->setGrouping(ItemGrouping::None);
    m_stazioni->setSortedAscending(false);

    //caricaordineinversoesalva();
}

void LocalDataManager::smartLoad(QString iniz)
{
    // Load the JSON data
    if (m_list.isEmpty())
        readJSON(m_dumpStazioniPath);

    QVariantMap staz;

    m_stazioni->clear();

    if (iniz.isEmpty() || iniz.isNull() || iniz.length() == 1) {

        foreach (QVariant stazione, m_list){
        staz=stazione.toMap();
        if(staz["lastSelected"].toLongLong() != 0) {
            staz["name"] = staz["name"].toString().toUpper();
            m_stazioni->insert(staz);
            //qDebug()<<staz;
        }
    }
}
else if (iniz.length() > 1) {
    foreach (QVariant stazione, m_list) {
        staz=stazione.toMap();
        if(staz["name"].toString().contains(iniz, Qt::CaseInsensitive)) {
            staz["name"]=staz["name"].toString().toUpper();

            m_stazioni->insert(staz);
        }
    }
}
}

void LocalDataManager::load(QString iniz)
{
    m_stazioni->clear();

    if (iniz.isNull() || iniz.isEmpty() || iniz.size() == 1)
        return;

    if (m_list.isEmpty())
        readJSON(m_dumpCodiciPath);

    foreach (QVariant stazione, m_list){
    QVariantMap staz=stazione.toMap();
    if(staz["name"].toString().contains(iniz, Qt::CaseInsensitive)) {
        staz["name"]=staz["name"].toString().toUpper();
        m_stazioni->insert(staz);
    }
}
}

void LocalDataManager::loadNearest()
{
    if (m_coord.isEmpty())
        readJSON(m_dumpViaggiatrenoPath);
    m_stazioni->clear();

    QGeoPositionInfoSource *src = QGeoPositionInfoSource::createDefaultSource(this);
    src->setProperty("canRunInBackground", true);
    src->setProperty("accuracy", 100.0);

    if (src->property("locationServicesEnabled").toBool()) {

        bool positionUpdatedConnected = connect(src, SIGNAL(positionUpdated(const QGeoPositionInfo &)), this, SLOT(onGPSFix(const QGeoPositionInfo &)));
        connect(src, SIGNAL(updateTimeout()), this, SLOT(onTimeout()));
        if (positionUpdatedConnected)
            src->requestUpdate();

    } else {
        SystemDialog* m_dialog = new SystemDialog("Ok", "Annulla");
        m_dialog->setTitle("Servizi di posizionamento disattivati");
        m_dialog->setBody("I servizi di posizionamento sono disattivati, attivarli nelle impostazioni del dispositivo?");
        bool success = connect(m_dialog, SIGNAL(finished(bb::system::SystemUiResult::Type)), this, SLOT(onDialogFinished(bb::system::SystemUiResult::Type)));
        if(success)
            m_dialog->show();
        else
            m_dialog->deleteLater();
    }

}

void LocalDataManager::onDialogFinished(bb::system::SystemUiResult::Type result)
{
    SystemDialog *m_dialog = qobject_cast<SystemDialog*>(sender());
    if (result == SystemUiResult::ConfirmButtonSelection) {

        // bring up the Settings app at the Location Services page so it can be turned on.
        InvokeManager invokeManager;
        InvokeRequest request;
        request.setAction("bb.action.OPEN");
        request.setMimeType("text/html");
        request.setUri("settings://location");
        request.setTarget("sys.settings.target");
        InvokeTargetReply *reply = invokeManager.invoke(request);
        if (reply)
            reply->deleteLater();    //i don't give a flying duck if invocation fails, i can't do anything different
        emit locationError("");
    }
    else emit locationError("Impossibile determinare la posizione");
    //otherwise we do nothing
    m_dialog->deleteLater();
}

void LocalDataManager::onTimeout()
{
    QGeoPositionInfoSource *src = qobject_cast<QGeoPositionInfoSource*>(sender());
    if (src->property("replyErrorCode").isValid()) {
        PositionErrorCode::Type err = src->property("replyErrorCode").value<PositionErrorCode::Type>();
        if (err == PositionErrorCode::FatalPermission)    //this is why i love bb10 OS
            emit locationError(QString::fromUtf8("All'app non è stato concesso il permesso di usare i servizi di localizzazione"));
        else
            emit locationError("Impossibile recuperare la posizione del dispositivo");
    }
    src->deleteLater();
}

void LocalDataManager::onGPSFix(const QGeoPositionInfo &fix)
{
    QGeoPositionInfoSource *src = qobject_cast<QGeoPositionInfoSource*>(sender());

    QGeoCoordinate gps = fix.coordinate();  //if i could be where you are..
    if (gps.type() != QGeoCoordinate::InvalidCoordinate) {

        //m_stazioni->clear();
        readJSON(m_dumpViaggiatrenoPath);
        QList<QVariantMap> stazioni;
        QVariantMap stazione;

        for (int i = 0; i < MAX_NEAREST_STATIONS; i++) {    //pretend the first stations are the closest..
            stazione = m_list[i].toMap();
            stazione["distance"] = getDistance(gps.latitude(), gps.longitude(), stazione["lat"].toDouble(), stazione["lon"].toDouble());
            stazioni.append(stazione);
        }
        qSort(stazioni.begin(), stazioni.end(), lessThan);

        for (int i = MAX_NEAREST_STATIONS; i < m_list.size(); i++) {    //..if a closer one is found update the list
            stazione = m_list[i].toMap();
            stazione["distance"] = getDistance(gps.latitude(), gps.longitude(), stazione["lat"].toDouble(), stazione["lon"].toDouble());
            if (stazione["distance"].toDouble() < stazioni.last()["distance"].toDouble()) {
                stazioni.append(stazione);
                qSort(stazioni.begin(), stazioni.end(), lessThan);    //very fast because there are just 6 elements in the list despite time being O(n logn)
                stazioni.removeLast();      //remove farthest to keep MAX_NEAREST_STATIONS size
            }
        }
        m_list.clear();
        for (int i = 0; i < stazioni.size(); i++)
            m_list.append(stazioni[i]);
        //emit nearestLoaded();
        SystemListDialog* m_listdialog;
        m_listdialog = new SystemListDialog("Annulla");
        //m_listdialog->setTitle("Seleziona stazione");
        m_listdialog->setBody("Seleziona stazione");
        m_listdialog->setDismissOnSelection(true);

        for (int i = 0; i < m_list.size(); i++) {
            stazione = stazione = m_list[i].toMap();
            QGeoCoordinate current(stazione["lat"].toDouble(), stazione["lon"].toDouble());
            m_listdialog->appendItem(stazione["name"].toString() + " (" + QString::number(gps.distanceTo(current)/1000, 'f', 1) + " km)");
        }
        bool success = connect(m_listdialog, SIGNAL(finished(bb::system::SystemUiResult::Type)), this, SLOT(onStationsDialogFinished(bb::system::SystemUiResult::Type)));

        if (success)
            m_listdialog->exec();
        else
            m_listdialog->deleteLater();	//se non riesce a connettersi si blocca la funzione..
    }
    src->deleteLater();
}

void LocalDataManager::onStationsDialogFinished(bb::system::SystemUiResult::Type result)
{
    SystemListDialog *m_dialog = qobject_cast<SystemListDialog*>(sender());
    if (result == SystemUiResult::ItemSelection) {
        int index = m_dialog->selectedIndices().value(0);
        emit nearestSelected(m_list.at(index).toMap()["name"].toString());
    }
    else
        emit nearestSelected(QString::null);

    m_list.clear();
    m_dialog->deleteLater();
}

double LocalDataManager::getDistance(double x1, double y1, double x2, double y2)
{
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

void LocalDataManager::save(QString from, QString to)
{    //saves last selected time
    readJSON(m_dumpStazioniPath);

    QVariantList _stazioni;
    QVariantMap stazione;
    //todo: ricerca dicotomica
    foreach(QVariant staz, m_list){
    stazione = staz.toMap();
    if(stazione["name"].toString().toUpper()==from || stazione["name"].toString().toUpper()==to) {
        stazione["lastSelected"]=(QDateTime::currentMSecsSinceEpoch()/1000);
        //qDebug()<<"-> gotcha "<<stazione["name"];
    }
    //qDebug() << stazione["name"] << " : " << stazione["lastSelected"];
    _stazioni << stazione;  //foreach with a non-const reference cannot modify the original container... gotta create a new one
}

    QVariant pualle(_stazioni);
    m_list = _stazioni;    //update the station data for the current searches
    writeJSON(m_dumpStazioniPath, pualle);    //... and the future ones
}

void LocalDataManager::encryptCredentials(const QString &user, const QString &pass)
{
    SimpleCrypt crypt(ENCRYPTION_KEY);

    QString encryptUser = crypt.encryptToString(user);
    QString encryptPass = crypt.encryptToString(pass);

    QFile file(m_credentialsPath);
    if (file.open(QIODevice::WriteOnly)) {
        QDataStream stream(&file);    // Open stream
        stream << encryptUser << encryptPass;
        file.close();
    }
}

QVariantMap LocalDataManager::decryptCredentials()
{
    SimpleCrypt crypt(ENCRYPTION_KEY);
    QString encryptUser, encryptPass;

    QFile file(m_credentialsPath);
    if (!file.open(QIODevice::ReadOnly))
        return QVariantMap();

    QDataStream stream(&file);    // Open stream
    stream >> encryptUser >> encryptPass;
    file.close();

    QVariantMap cred;
    cred["user"] = crypt.decryptToString(encryptUser);
    cred["pass"] = crypt.decryptToString(encryptPass);

    return cred;
}

void LocalDataManager::deleteCredentials()
{
    QFile file(m_credentialsPath);
    if (file.exists())
        file.remove();
}

void LocalDataManager::readJSON(const QString &path)
{
    JsonDataAccess jda;
    m_list = jda.load(path).toList();
    //qDebug()<<jda.hasError();
}

void LocalDataManager::writeJSON(const QString &path, QVariant &data)
{
    JsonDataAccess jda;
    jda.save(data, path);
}

void LocalDataManager::cleanup()
{
    m_list.clear();
}

void LocalDataManager::reset()
{
    m_stazioni->clear();
}

bb::cascades::DataModel* LocalDataManager::stazioni() const
{
    return m_stazioni;
}

void LocalDataManager::caricaordineinversoesalva()
{
    readJSON(m_dumpCodiciPath);

    QVariantList _stazioni;
    QVariantMap stazione;

    foreach(QVariant staz, m_list){
    stazione = staz.toMap();

    QString name, nameOrd = "";
    name = stazione["name"].toString().toUpper();

    for(int i = 0; i < name.size(); i++) {
        if(name[i]>='A' && name[i]<='Z')
        nameOrd += ('A' + 'Z' - name[i].toAscii());
        else nameOrd += name[i];
    }
    stazione["nameOrd"] = nameOrd;
    stazione["lastSelected"]=0;

    _stazioni << stazione;//foreach with a non-const reference cannot modify the original container... gotta create a new one
}

    QVariant pualle(_stazioni);
    writeJSON("./data/dump_codici.json", pualle);
}

/*void LocalDataManager::eliminaStazioniSenzaCoordinate()
 {

 QVariantList newList;
 QVariantMap stazione;

 foreach(QVariant staz, m_list){
 stazione = staz.toMap();
 if(stazione["lat"].toString() != "N/A" && stazione["lon"] != "N/A") {
 newList << staz;
 }

 }

 QVariant pualle(newList);
 writeJSON("./data/dump_coordinate.json", pualle); //... and the future ones
 }*/
