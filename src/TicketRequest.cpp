/*
 * TicketRequest.cpp
 *
 *  Created on: 20/feb/2018
 *      Author: Simone
 */

#include <src/TicketRequest.hpp>
#include <src/ArtifactRequest.hpp>
#include <bb/data/JsonDataAccess>
#include <QtCore/QObject>

using namespace bb::data;
using namespace bb::system;

TicketRequest::TicketRequest(QNetworkAccessManager* qnam, QObject* parent) : QObject(parent)
{
    m_qnam = qnam;
    m_progresstoast = NULL;
}

void TicketRequest::openTicket(const QString &id, const QString &tsid){     //entry point for opening a ticket
    m_id=id;
    m_tsid=tsid;

    JsonDataAccess dataAccess;
    QVariantMap ticketList = dataAccess.load("./data/tickets.dat").toMap();
    if(ticketList.contains(id)){
        openAdobeReader(ticketList[id].toString());    //ticket had already been downloaded, just open it
    }else{
        downloadTicket();
    }
}

void TicketRequest::downloadTicket(){

    ArtifactRequest* downloadRequest = new ArtifactRequest(m_qnam, this);
    connect(downloadRequest, SIGNAL(complete(QString, bool, int)), this, SLOT(onSaleComplete(QString, bool, int)));

    //downloadRequest->download("https://www.lefrecce.it/msite/api/users/sales/" + id + "/travel?lang=it-IT&tsid=1");
    downloadRequest->requestArtifactline("https://www.lefrecce.it/msite/api/users/sales/" + m_id);
}

void TicketRequest::onSaleComplete(const QString &info, bool success, int i){

    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    connect(request, SIGNAL(downloadComplete(QByteArray&, QString, bool)), this, SLOT(onDownloadComplete(QByteArray&, QString, bool)));
    connect(request, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(onDownloadProgress(qint64, qint64)));

    request->download("https://www.lefrecce.it/msite/api/users/sales/" + m_id + "/travel?lang=it-IT&tsid=" + m_tsid);

}

void TicketRequest::onDownloadComplete(QByteArray &data, QString filename, bool success){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(success){
        QFile file("./shared/downloads/" + filename);   //try saving it in shared space if user granted permission
        if(!file.open(QIODevice::WriteOnly)){
            file.setFileName("./data/" + filename);     //otherwise save it in app folder
            if (!file.open(QIODevice::WriteOnly)) {
                this->deleteLater();
                return;
            }
        }
        file.write(data);
        file.close();

        openAdobeReader(filename);

        QFile tickets("./data/tickets.dat");    //save an index of all downloaded tickets to avoid wasting mobile data
        //QVariantList list;
        QVariantMap current;
        JsonDataAccess dataAccess;

        if(tickets.open(QIODevice::ReadOnly)){      //preserve old entries, dataAccess replaces the file
            QByteArray data = tickets.readAll();
            tickets.close();
            current = dataAccess.loadFromBuffer(data).toMap();
        }

        current[m_id] = filename;
        QVariant pualle(current);
        dataAccess.save(pualle, "./data/tickets.dat");
    }
    else{
        emit badResponse("Impossibile scaricare il biglietto.");
        this->deleteLater();
    }
    request->deleteLater();
    this->deleteLater();
}

void TicketRequest::onDownloadProgress(qint64 received, qint64 total){
    if(!m_progresstoast){   //1st time
        m_progresstoast = new SystemProgressToast(this);
        m_progresstoast->setBody("Scaricamento PDF in corso...");
        m_progresstoast->setState(SystemUiProgressState::Active);
        m_progresstoast->setPosition(SystemUiPosition::MiddleCenter);
        m_progresstoast->setProgress(-1);   //progress percentage doesn't work with trenitalia server..
        m_progresstoast->show();
    }
    else if(total == -1)
        m_progresstoast->update();  //keep alive

//progresstoast is deleted as soon as the class self destructs after opening the pdf
}

void TicketRequest::openAdobeReader(const QString &filename){
        InvokeManager manager;
        InvokeRequest request;

        request.setTarget("com.rim.bb.app.adobeReader.viewer");
        request.setAction("bb.action.VIEW");
        request.setMimeType("application/pdf");

        QString uri = "file:///";
        uri = uri.append(QDir::currentPath());
        if(QFile::exists("./shared/downloads/" + filename))
            uri += + "/shared/downloads/" + filename;
        else if(QFile::exists("./data/" + filename))    //maybe user didn't grant premission to save in shared space, check in app folder
            uri +=  + "/data/" + filename;
        else{
            downloadTicket();   //file isn't there (user deleted it), download it again..
            return;
        }

        qDebug()<<"file uri: "<<uri;

        request.setUri(QUrl(uri));

        InvokeTargetReply *reply = manager.invoke(request);
        reply->setParent(this);
        connect(reply, SIGNAL(finished()), this,  SLOT(onInvokeResult()));
        m_reply = reply;

        //this->deleteLater();
}

void TicketRequest::onInvokeResult(){   //helper function pasted stright from docs, saves a lot of headaches
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

