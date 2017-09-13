/*
 * ProfileRequest.cpp
 *
 *  Created on: 09/lug/2017
 *      Author: Simone
 */

#include <src/ArtifactRequest.hpp>
#include <src/ProfileRequest.hpp>
#include <bb/data/JsonDataAccess>
#include <QtCore/QObject>
#include <QFile>
#include <QMap>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTargetReply>
#include <QDir>

using namespace bb::data;
using namespace bb::system;

ProfileRequest::ProfileRequest(QNetworkAccessManager* qnam, QVariantMap* profile, bb::cascades::GroupDataModel* tickets, QObject* parent) : QObject(parent)
{
    m_qnam = qnam;
    m_profile = profile;
    m_tickets = tickets;
    m_openRequests=0;
    m_progresstoast = NULL;
}

void ProfileRequest::login(QString user, QString pass){     //entry point for login button
    ArtifactRequest* login = new ArtifactRequest(m_qnam, this);

    connect(login, SIGNAL(complete(QString, bool, int)), this, SLOT(onLogin(QString, bool, int)));
    connect(login, SIGNAL(moved()), this, SLOT(badCredentials()));

    QByteArray postData;
    postData.append("j_username=" + user + "&j_password=" + pass);

    login->post("https://www.lefrecce.it/msite/api/users/login", postData);

}

void ProfileRequest::badCredentials(){
    emit badResponse("Credenziali di login errate.");
    this->deleteLater();
}

void ProfileRequest::getData(){     //entry point when already logged

    ArtifactRequest* profileRequest = new ArtifactRequest(m_qnam, this);
    connect(profileRequest, SIGNAL(complete(QString, bool, int)), this, SLOT(onProfileComplete(QString, bool, int)));
    m_openRequests++;

    profileRequest->requestArtifactline("https://www.lefrecce.it/msite/api/users/profile");

    ArtifactRequest* lastTickets = new ArtifactRequest(m_qnam, this);
    connect(lastTickets, SIGNAL(complete(QString, bool, int)), this, SLOT(onTicketsComplete(QString, bool, int)));
    m_openRequests++;

    QDate dateTo = QDate::currentDate();
    QDate dateFrom = QDate(dateTo);
    dateFrom = dateFrom.addMonths(-3);

    lastTickets->requestArtifactline("https://www.lefrecce.it/msite/api/users/purchases?finalized=true&datefrom=" + dateFrom.toString("dd/MM/yyyy") + "&dateto=" + dateTo.toString("dd/MM/yyyy"));

}

void ProfileRequest::openTicket(const QString &id, const QString &tsid){     //entry point for opening a ticket

    JsonDataAccess dataAccess;
    QVariantMap tickets = dataAccess.load("./data/tickets.dat").toMap();
    if(tickets.contains(id)){
        openAdobeReader(tickets[id].toString());
    }else{
        downloadTicket(id, tsid);
    }
}

void ProfileRequest::downloadTicket(const QString &id, const QString &tsid){
    m_id=id;
    m_tsid=tsid;

    ArtifactRequest* downloadRequest = new ArtifactRequest(m_qnam, this);
    connect(downloadRequest, SIGNAL(complete(QString, bool, int)), this, SLOT(onSaleComplete(QString, bool, int)));

    //downloadRequest->download("https://www.lefrecce.it/msite/api/users/sales/" + id + "/travel?lang=it-IT&tsid=1");
    downloadRequest->requestArtifactline("https://www.lefrecce.it/msite/api/users/sales/" + id);
}

void ProfileRequest::onLogin(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(success)
        getData();
    else{
        emit badResponse("Credenziali di login errate");
        this->deleteLater();
    }

    request->deleteLater();
}

void ProfileRequest::onSaleComplete(const QString &info, bool success, int i){

    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    connect(request, SIGNAL(downloadComplete(QByteArray&, QString, bool)), this, SLOT(onDownloadComplete(QByteArray&, QString, bool)));
    connect(request, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(onDownloadProgress(qint64, qint64)));

    request->download("https://www.lefrecce.it/msite/api/users/sales/" + m_id + "/travel?lang=it-IT&tsid=" + m_tsid);

}

void ProfileRequest::onDownloadComplete(QByteArray &data, QString filename, bool success){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(success){
        QFile file("./data/" + filename);
            if (!file.open(QIODevice::WriteOnly)) {
                this->deleteLater();
                return;
            }
        file.write(data);
        file.close();

        QFile tickets("./data/tickets.dat");    //save an index of all downloaded tickets to avoid duplicates
        //QVariantList list;
        QVariantMap current;
        JsonDataAccess dataAccess;

            if(!tickets.open(QIODevice::ReadOnly)){     //1st time
               current[m_id] = filename;
               QVariant pualle(current);
               dataAccess.save(pualle, "./data/tickets.dat");

            }
            else{
                QByteArray data = tickets.readAll();
                tickets.close();
                current = dataAccess.loadFromBuffer(data).toMap();
                current[m_id] = filename;
                QVariant pualle(current);
                dataAccess.save(pualle, "./data/tickets.dat");
        }
        openAdobeReader(filename);
    }
    else{
        emit badResponse("Impossibile scaricare il biglietto.");
        this->deleteLater();
    }
    request->deleteLater();
}

void ProfileRequest::onDownloadProgress(qint64 received, qint64 total){
    if(!m_progresstoast){   //1st time
        m_progresstoast = new SystemProgressToast(this);
        m_progresstoast->setBody("Scaricamento PDF in corso...");
        m_progresstoast->setState(SystemUiProgressState::Active);
        m_progresstoast->setPosition(SystemUiPosition::MiddleCenter);
        m_progresstoast->setProgress(-1);
        m_progresstoast->show();
    }
    else if(total == -1)
        m_progresstoast->update();  //keep alive

//progresstoast is deleted as soon as the class self destructs after opening the pdf
}

void ProfileRequest::onProfileComplete(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());
    if(success){
        if(!info.isEmpty() && !info.isNull()){
            m_profile->clear();
            JsonDataAccess dataAccess;
            m_profile->unite(dataAccess.loadFromBuffer(info).toMap());
            m_profile->insert("logged", true);
        }else emit badResponse("Impossibile recuperare i dati di questo utente.");

    }else emit badResponse(info);

    request->deleteLater();

    m_openRequests--;
    if(!m_openRequests){
        emit finished();
        this->deleteLater();
    }
}

void ProfileRequest::onTicketsComplete(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());
    if(success){
        if(!info.isEmpty() && !info.isNull()){
            m_tickets->clear();
            JsonDataAccess dataAccess;
            QVariantList list = dataAccess.loadFromBuffer(info).toList();
            m_tickets->insertList(list);
        }else emit badResponse("Impossibile recuperare gli ultimi viaggi questo utente.");

    }else emit badResponse(info);

    request->deleteLater();

    m_openRequests--;
    if(!m_openRequests){
        emit finished();
        this->deleteLater();
    }
}

void ProfileRequest::openAdobeReader(const QString &filename){
        InvokeManager manager;
        InvokeRequest request;

        request.setTarget("com.rim.bb.app.adobeReader.viewer");
        request.setAction("bb.action.VIEW");
        request.setMimeType("application/pdf");
        QString uri = "file:///";
        uri = uri.append(QDir::currentPath());
        uri +=  + "/data/" + filename;
        request.setUri(QUrl(uri));

        InvokeTargetReply *reply = manager.invoke(request);
        reply->setParent(this);
        connect(reply, SIGNAL(finished()), this,  SLOT(onInvokeResult()));
        m_reply = reply;

        this->deleteLater();
}

void ProfileRequest::onInvokeResult(){
    // Check for errors
    switch(m_reply->error()) {
        // Invocation could not find the target;
        // did we use the right target ID?
        case InvokeReplyError::NoTarget: {
            qDebug() << "invokeFinished(): Error: no target" << endl;
            break;
        }

        // There was a problem with the invocation request;
        // did we set all of the values correctly?
        case InvokeReplyError::BadRequest: {
            qDebug() << "invokeFinished(): Error: bad request" << endl;
            break;
        }

        // Something went completely
        // wrong inside the invocation request,
        // so find an alternate route
        case InvokeReplyError::Internal: {
            qDebug() << "invokeFinished(): Error: internal" << endl;
            break;
        }

        // Message received if the invocation request is successful
        default:
            qDebug() << "invokeFinished(): Invoke Succeeded" << endl;
            break;
    }
}
