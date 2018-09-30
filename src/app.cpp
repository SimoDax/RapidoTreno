#include <src/app.hpp>
#include <src/ArtifactRequest.hpp>
#include <src/StatusRequest.hpp>
#include <src/ItaloStatusRequest.hpp>
#include <src/LocalDataManager.hpp>
#include <src/StazioneStatusRequest.hpp>
#include <src/ProfileRequest.hpp>
#include <src/TicketRequest.hpp>
#include <src/DetailedOffersRequest.hpp>
#include <src/NewsRequest.hpp>

#include <bb/cascades/AbstractPane>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/system/SystemDialog>
#include <bb/cascades/ListView>
#include <bb/PpsObject>
#include <bb/cascades/VisualStyle>
#include <bb/cascades/ThemeSupport>

#include <bb/data/JsonDataAccess>
#include <bb/data/XmlDataAccess>
#include <bb/utility/i18n/RelativeDateFormatter>

#include <QDateTime>
#include <QVariant>

using namespace bb::cascades;
using namespace bb::data;
using namespace bb::system;

const QString App::m_filePath = "./data/ricerche.dat";
//const QString App::m_prefPath = "./data/pref.dat";
const QString App::m_stazioniPath = "./data/stazioni.dat";
const QString App::m_dumpStazioniPath = "./data/dump_2_6.json";

//Q_DECLARE_METATYPE(QList<QVariantMap>)

/*
 * Default constructor
 */
//! [0]
App::App(QObject *parent)   //where it all began
    : QObject(parent)
    , m_active(false)
    , m_pend(false)
    , m_logged(false)
    , m_model(new GroupDataModel(QStringList() << "departuretime", this))
    , m_stazioni(new GroupDataModel(QStringList() << "distance" << "lastSelected" << "name", this))
    , m_news(new GroupDataModel(QStringList() << "timestamp", this))
    , m_stazioneStatus(new GroupDataModel(QStringList()<<"orarioPartenza", this))
    , m_tickets(new GroupDataModel(QStringList()<<"idsales", this))
    , m_solutionDetails(new GroupDataModel(QStringList() << "departuretime", this))
    , m_ricerche(new ArrayDataModel(this))
    , m_statusData(new QVariantMap())
    , m_profile(new QVariantMap())
    , m_preloaded(new QVector<QVariantList>)
    , m_trainsDetails(new QVariantList)
{
    qmlRegisterType<LocalDataManager>("Storage.LocalDataManager", 1, 0, "LocalDataManager");


    m_model->setGrouping(ItemGrouping::None);
    m_stazioni->setGrouping(ItemGrouping::None);
    m_stazioni->setSortedAscending(false);
    m_news->setGrouping(ItemGrouping::None);
    m_solutionDetails->setGrouping(ItemGrouping::None);
    m_stazioneStatus->setGrouping(ItemGrouping::None);
    m_news->setSortedAscending(false);
    m_tickets->setSortedAscending(false);
    m_tickets->setGrouping(ItemGrouping::None);
    m_qnam = new QNetworkAccessManager(this);

    QmlDocument* qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("_artifactline", this);

    QSettings settings("simodax","rapidotreno");
    if(settings.value("style", 0).toInt())
        Application::instance()->themeSupport()->setVisualStyle(settings.value("style").toInt());
    qDebug()<<settings.value("style", 0).toInt();

    root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);

    //resetOffset();

    QString part, arr;
    int state;
    QDateTime t = QDateTime::currentDateTime();
    QFile file(m_stazioniPath);
    if(file.open(QIODevice::ReadOnly)){
        //return;
        QDataStream stream(&file); // Open stream
        stream >> state;
        if (state){
            stream >> part;
            stream >> arr;
            QObject *partTxt = root->findChild<QObject*>("partTxt");
            QObject *arrTxt = root->findChild<QObject*>("arrTxt");
            QObject *main = root->findChild<QObject*>("main");
            if(t.toString("h")<"12"){
                partTxt->setProperty("text", part);
                arrTxt->setProperty("text", arr);
                main->setProperty("stazpart", part);
                main->setProperty("stazarr", arr);
            }
            else{
                partTxt->setProperty("text", arr);
                arrTxt->setProperty("text", part);
                main->setProperty("stazpart", arr);
                main->setProperty("stazarr", part);
            }
            main->setProperty("da_ready", true);
            main->setProperty("a_ready", true);
            m_pend = true;
            emit pendChanged();
        }
        else{
            m_pend = false;
            emit pendChanged();
        }
        file.close();
    }

    if(!QFile::exists(m_dumpStazioniPath)){
        bool ok = QFile::copy( "./app/native/assets/dump_2_6.json", m_dumpStazioniPath);
        qDebug() << "Copy of JSON file success=" << ok;
    }
    else qDebug()<< "File exists: " << m_dumpStazioniPath;

}
//! [0]
void App::reset()
{
    m_errorMessage.clear();

    emit statusChanged();
}

void App::requestArtifact(const QString &da, const QString &a, const QString &dt, const QString &adulti, const QString &bambini, const QString &frecce, bool italo, bool silent)
{
    if (m_active)
        return;

    m_model->clear();
     //QString artifactName = "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/soluzioniViaggioNew/" + da + "/" + a + "/" + dt;    //old viaggiatreno url
    QDateTime t = QDateTime::fromString(dt, Qt::ISODate);

    //m_adulti = adulti;
    //m_bambini = bambini;

    TrainRequest * request = new TrainRequest(m_qnam, m_model, m_preloaded, italo, this);
    //m_openRequests++;

    if(!silent)
        connect(request, SIGNAL(finished()), this, SIGNAL(artifactsLoaded()), Qt::UniqueConnection);
    else
        connect(request, SIGNAL(finished()), this, SIGNAL(removeWait()), Qt::UniqueConnection);

    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    request->getSolutions(da, a, t, adulti, bambini, frecce, italo);

}

QString App::errorMessage() const
{
    return m_errorMessage;
}

QString App::dateFromTimestamp(const QString &timestamp) {
	QDateTime date;
	date.setMSecsSinceEpoch(timestamp.toLongLong());
	return date.toString();
}

bb::cascades::DataModel* App::model() const
{
    return m_model;
}

bb::cascades::DataModel* App::stazioni() const
{
    return m_stazioni;
}

bb::cascades::DataModel* App::ricerche() const
{
    return m_ricerche;
}

bb::cascades::DataModel* App::news() const
{
    return m_news;
}

bb::cascades::DataModel* App::solutionDetails() const
{
    return m_solutionDetails;
}

bb::cascades::DataModel* App::stazioneStatus() const
{
    return m_stazioneStatus;
}

bb::cascades::DataModel* App::tickets() const
{
    return m_tickets;
}

QVariantMap App::profileData() const
{
    return *m_profile;
}


void App::resetStazioni(){
    m_stazioni->clear();
}

void App::requestStatusData(const QString &num){
    if (num.isEmpty()||num.isNull()) {

        emit statusChanged();
        return;
    }
    //if(num.contains(QRegExp("\\d"))){

    StatusRequest* request = new StatusRequest(m_qnam, m_statusData, this);
    bool ok = connect(request, SIGNAL(finished()), this, SIGNAL(statusDataLoaded()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);
    request->requestStatusData(num);

}

void App::requestStatusDataItalo(const QString &num){
    if (num.isEmpty()||num.isNull() || num.toInt() < 8900 || num.toInt()> 9999) {

        emit badResponse("Errore");
        return;
    }
    //if(num.contains(QRegExp("\\d"))){

    ItaloStatusRequest* requestStatus = new ItaloStatusRequest(m_qnam, m_statusData, this);
    bool ok = connect(requestStatus, SIGNAL(finished()), this, SIGNAL(statusDataLoaded()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
    connect(requestStatus, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    requestStatus->requestStatusData(num);

}

QVariant App::requestStatusField(const QString &field, const int &field2, const QString &field3){
    const QVariantList fermate = m_statusData->value(field).toList();
    if(field2 >= 0 && field2 < fermate.size()){
    const QVariantMap fermata = fermate[field2].toMap();
    return fermata.value(field3);
    }
    else{
        QVariant x;
        return x;
    }
}

QVariant App::requestStatusField(const QString &field, const int &field2){
    const QVariantList lista = m_statusData->value(field).toList();
    return lista[field2];
}

QVariant App::requestStatusField(const QString &field){
    return m_statusData->value(field);
}

void App::salvaRicerca(QString num){        //TODO: this is low level c-style file managing .-.
    QFile file(m_filePath);
    if(!file.exists()){
        file.open(QIODevice::WriteOnly);
        file.close();
    }
    if (!file.open(QIODevice::ReadOnly))
        return;
    QTextStream streamR(&file); // Open a stream into the file.
    QStringList lista;
    while(!streamR.atEnd()){
        lista.append(streamR.readLine()+"\n");
    }
    file.close();

    if(lista.isEmpty())
        lista.append(num + "\n");
    else if (lista.contains(num + "\n"))
        return;
    else if(lista.size() >= 5){
        for(int i=0; i<4; i++)
            lista[i]=lista[i+1];
        lista[4] = num + "\n";
    }
    else lista.append(num + "\n");

    if(!file.open(QIODevice::WriteOnly|QIODevice::Text))
        return;
    QTextStream streamW(&file);
    m_ricerche->clear();
    for(int i=0; i<lista.size(); i++){
        streamW << lista[i];
        m_ricerche->append(lista[i]);
    }
    for(int k=0, s=m_ricerche->size(), max=(s/2); k<max; k++) m_ricerche->swap(k,s-(1+k));
    file.close();
}

void App::caricaRicerche(){
    QFile file(m_filePath);
        if (!file.open(QIODevice::ReadOnly))
            return;
        QTextStream streamR(&file); // Open a stream into the file.

        //QStringList lista;
        m_ricerche->clear();
        while(!streamR.atEnd()){
            m_ricerche->append(streamR.readLine());
        }
        file.close();
        for(int k=0, s=m_ricerche->size(), max=(s/2); k<max; k++) m_ricerche->swap(k,s-(1+k));
        //emit ricercheLoaded();
}
/*void App::setDestinazione(const QVariantList &indexPath){
    ListView *list = root->findChild<ListView*>("lista");
}*/

void App::requestFSNews(){

    NewsRequest* request = new NewsRequest(m_qnam, m_news, this);
    connect(request, SIGNAL(finished()), this, SIGNAL(newsLoaded()), Qt::UniqueConnection);
    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    request->getNews();

}

void App::salvaEvento(const QVariantList indexPath){
    InvokeManager manager;
    InvokeRequest request;

    request.setTarget("sys.pim.calendar.viewer.eventcreate");
    request.setAction("bb.action.CREATE");
    request.setMimeType("text/calendar");

    QVariantMap evento;
    QVariant subj = m_model->data(indexPath);
    QVariantMap subject = subj.toMap();
    QString num;
    if(subject["changesno"] == 0){
       // QVariantMap treno = subject[0].toMap();
        num = subject["numeroTreno"].toString();
        QString cat = subject["traintype"].toString();
        if (cat == "italo")
            evento.insert("subject", "Treno Italo " + num);
        else
            evento.insert("subject", "Treno " + num);

    }else{
        num=subject["numeroTreno"].toString();
        //num += treno.toMap()["numeroTreno"].toString();
        //QString cat = subject["categoriaDescrizione"].toString();
        num = num.replace(",", " / ");
        //cat = cat.split(",", QString::SkipEmptyParts)[0];
        evento.insert("subject", "Treno " + num);
    }
    QVariant orario = subject["departuretime"];
    QDateTime t = QDateTime::fromMSecsSinceEpoch(orario.toLongLong());
    evento.insert("startTime", t.toString("yyyy-MM-dd HH:mm:ss"));

    QString dur = subject["duration"].toString();
    QStringList dur_ = dur.split(":", QString::SkipEmptyParts);
    evento.insert("duration", dur_[0].toInt()*60 + dur_[1].toInt());
    request.setData(bb::PpsObject::encode(evento, NULL));
    manager.invoke(request);
}

void App::setSolutionDetailsModel(const QVariantList indexPath){
    m_solutionDetails->clear();
    int a = m_model->size();
    int b = m_preloaded->size();
    QObject* o = root->findChild<QObject*>("tl");
    //connect(this, SIGNAL(showDetails()), o, SLOT(pushPane()), static_cast<Qt::ConnectionType>(Qt::QueuedConnection | Qt::UniqueConnection));
    //if(m_model->size() == m_preloaded->size()){
    //qSort(m_preloaded->begin(), m_preloaded->end(), lessThan);
    m_solutionDetails->insertList(m_preloaded->at(indexPath[0].toInt()));
    emit showDetails();
    for(int i = 0; i< m_preloaded->size(); i++){
        //qDebug()<<m_preloaded->at(i)[0].toMap()["idsolution"];
       // qDebug()<<m_preloaded->at(i)[0].toMap()["departuretime"];
        //i hope compiler optimizes this away, too lazy to comment the whole cycle
    }

    //originally solution details weren't loaded before showing the search results,
    //this code made sure users could not open travels the app did not have details of yet
    /*else{
        connect(this, SIGNAL(displayWait()), o, SLOT(displayWait()), static_cast<Qt::ConnectionType>(Qt::QueuedConnection | Qt::UniqueConnection));
        emit displayWait();
        while(m_model->size() != m_preloaded->size())
            QApplication::processEvents();
        emit removeWait();
        emit showDetails();
    }*/

}

void App::clearPreloaded(){
    m_preloaded->clear();
}

void App::pagah(const QVariantList indexPath, const QString &adulti, const QString &bambini){
    QString url;
    InvokeManager manager;
    InvokeRequest request;

    QVariantMap soluzione = m_model->data(indexPath).toMap();

    if(soluzione["traintype"] == "italo")
        url="http://www.italotreno.it";
    else{
        QDateTime t = QDateTime::fromMSecsSinceEpoch(soluzione["departuretime"].toLongLong());
        url = "https://www.lefrecce.it/msite/?lang=it#search?noOfAdults="+adulti+"&ynFlexibleDates=&arrivalStation="+soluzione["destination"].toString()+"&isRoundTrip=false&selectedTrainClassification=&tripType=on&selectedTrainType=tutti&departureStation="+soluzione["origin"].toString()+"&parameter=initBaseSearch&departureDate="+ t.toString("dd-MM-yyyy") +"&departureTime="+ t.toString("H") +"&noOfChildren="+bambini;
    }

    request.setTarget("sys.browser");
    request.setAction("bb.action.OPEN");
    request.setMimeType("text/html");
    request.setUri(url);
    manager.invoke(request);

}

void App::switchPend(const QString &part, const QString &arr){
    QFile file(m_stazioniPath);
    if(m_pend){     //switch to disabled
        if(!file.open(QIODevice::WriteOnly))
            return;
        QDataStream stream(&file); // Open stream
        stream << 0;
        m_pend = false;
        emit pendChanged();
        emit pendToast();
    }else{          //switch to enabled
        QDateTime t = QDateTime::currentDateTime();
        if(!file.open(QIODevice::WriteOnly))
            return;
        QDataStream stream(&file); // Open stream
        if(t.toString("h")<"12")
            stream << 1 << part << arr;
        else
            stream << 1 << arr << part;
        m_pend = true;
        emit pendChanged();
        emit pendToast();
    }
    file.close();
}

bool App::pend() const {
    return m_pend;
}

void App::saveSetting(const QString &key, const QVariant &value){
    QSettings settings("simodax","rapidotreno");
    settings.setValue(key,value);
}

QVariant App::loadSetting(const QString &key){
    QSettings settings("simodax","rapidotreno");
    return settings.value(key);
}


QVariantMap App::statusData() const{
    return *m_statusData;
}

void App::requestStation(QString num){
    StazioneStatusRequest* request = new StazioneStatusRequest(m_qnam, m_stazioneStatus, this);

    connect(request, SIGNAL(finished()), this, SIGNAL(stationDataLoaded()), Qt::UniqueConnection);
    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    request->getStationData(num);
}

void App::requestAreaPers(QString user, QString pass){
    ProfileRequest* request = new ProfileRequest(m_qnam, m_profile, m_tickets, this);

    connect(request, SIGNAL(finished()), this, SIGNAL(profileLoaded()), Qt::UniqueConnection);
    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    if(user == "" && pass == ""){   //skip login
        request->getData();
    }else{
        request->login(user, pass);
    }
}

void App::openTicket(const QString &id, const QString &tsid){
    TicketRequest* request = new TicketRequest(m_qnam, this);

    request->openTicket(id, tsid);
}

bool App::loggedIn(){
    if(!m_profile)
        return false;
    if(m_profile->value("logged") == true)
        return true;
    else return false;  //includes false and null value
}

void App::requestOffers(QString id, bool custom){
    DetailedOffersRequest* request = new DetailedOffersRequest(m_qnam, m_trainsDetails);
    connect(request, SIGNAL(finished()), this, SIGNAL(offersLoaded()), Qt::UniqueConnection);
    connect(request, SIGNAL(badResponse(QString)), this, SIGNAL(badResponse(QString)), Qt::UniqueConnection);

    request->getDetails(id, custom);

}

QVariantList App::trainsDetails() const{
    return *m_trainsDetails;
}
