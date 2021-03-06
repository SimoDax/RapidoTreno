#include "ArtifactRequest.hpp"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QDebug>
#include <QFile>

/*
 * Default constructor
 */
ArtifactRequest::ArtifactRequest(QNetworkAccessManager* networkAccessManager, QObject *parent, int i) : QObject(parent)
{
    m_i = i;
    m_networkAccessManager = networkAccessManager;
}


void ArtifactRequest::requestArtifactline(const QString &url)
{

    const QString queryUri = QString::fromLatin1("%1").arg(url);
    //const QString queryUri = QString::fromLatin1("http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/soluzioniViaggioNew/1320/1322/2016-08-26T00:00:00").arg(url);  //dusty cretonne

    QUrl url_;
    url_.setEncodedUrl(url.toUtf8());

    qDebug()<<url_.toEncoded(QUrl::None);

    QNetworkRequest request(url_);

    QNetworkReply* reply = m_networkAccessManager->get(request);

    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(onArtifactlineReply()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
}

void ArtifactRequest::onArtifactlineReply()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    bool success = false;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            success = true;
            const int available = reply->bytesAvailable();
            if (available > 0) {
                const QByteArray buffer = reply->readAll();
                response = QString::fromUtf8(buffer);
                //success = true;
            }
        } else {
            response = "Errore di rete: " + reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString() + " " + reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        }
        //qDebug()<< "Page was loaded from cache: " <<reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute);
        reply->deleteLater();
    }

    /*if (response.trimmed().isEmpty()) {
        response = tr("request failed. Check internet connection");    //decommentare questo sovrascrive tutti i messaggi d'errore
    }*/

    emit complete(response, success, m_i);
}

void ArtifactRequest::post(const QString &url, const QByteArray &postData)
{
    const QString queryUri = QString::fromLatin1("%1").arg(url);

    QUrl url_;
    url_.setEncodedUrl(url.toUtf8());

    qDebug()<<url_.toEncoded(QUrl::None);


    QNetworkRequest postRequest(url_);
        //italoRequest.setRawHeader("User-Agent", "runscope/0.1");      //i'm not a phone, i swear
    postRequest.setRawHeader("Content-Type", "application/x-www-form-urlencoded");


    QNetworkReply* reply = m_networkAccessManager->post(postRequest, postData);

    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(onPostReply()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);

}

void ArtifactRequest::postJson(const QString &url, const QByteArray &postData)
{
    const QString queryUri = QString::fromLatin1("%1").arg(url);

    QUrl url_;
    url_.setEncodedUrl(url.toUtf8());

    qDebug()<<url_.toEncoded(QUrl::None);


    QNetworkRequest postRequest(url_);

    postRequest.setRawHeader("User-Agent", "android-async-http/1.4.4 (http://loopj.com/android-async-http)");      //i'm not a blackberry, i swear
    postRequest.setRawHeader("Content-Type", "application/json");
    postRequest.setRawHeader("Accept-Encoding", "gzip");
    postRequest.setRawHeader("Connection", "Keep-Alive");


#ifdef QT_DEBUG     //only in debug builds

    QFile file("./data/rawHeaders.txt");
        if(!file.open(QIODevice::WriteOnly))
            return;
        QTextStream stream(&file); // Open stream
        foreach(QByteArray header, postRequest.rawHeaderList())
            stream << header;
        file.close();

#endif

    QNetworkReply* reply = m_networkAccessManager->post(postRequest, postData);

    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(onPostReply()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);

}

void ArtifactRequest::onPostReply(){

    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QString response;
    bool success = false;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            success = true;     //success is set before checking if there is data in the answer: this class just handles http connection faliures,
                                //invalid data is managed by the upper classes
            if (available > 0) {
                const QByteArray buffer = reply->readAll();
                response = QString::fromUtf8(buffer);
                //success = true;
            }
        } else {
            response =  tr("Error: %1 status: %2").arg(reply->errorString(), reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString());
            qDebug()<<response;
        }
        //qDebug()<< "Page was loaded from cache: " <<reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute);


    qDebug()<<"success: "<<success;
       //if (success) {
       if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute) != 302){
           //m_openRequests--;
           emit complete(response, success, m_i);
       }
       else emit moved();
       //}
       reply->deleteLater();
    }
}

/*
void ArtifactRequest::onPostReplyWithCookies(){

    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    //QList<QNetworkCookie> cookies;
    QString response;
    bool success = false;
    if (reply) {
        if (reply->error() == QNetworkReply::NoError) {
            const int available = reply->bytesAvailable();
            success = true;     //success is set before checking if there is data in the answer: this class just handles http connection faliures,
                                //invalid data is managed by the upper classes
            if (available > 0) {
                const QByteArray buffer = reply->readAll();
                response = QString::fromUtf8(buffer);
                //success = true;
            }

            //QVariant cookies = (reply->header(QNetworkRequest::SetCookieHeader));
        } else {
            response =  tr("Error: %1 status: %2").arg(reply->errorString(), reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toString());
            qDebug()<<response;
            qDebug()<<QString::fromUtf8(reply->readAll());
        }
        //qDebug()<< "Page was loaded from cache: " <<reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute);


    qDebug()<<"success: "<<success;
       //if (success) {
       if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute) != 302){
           //m_openRequests--;
           //emit completeWithCookies(response, success, m_i, cookies);
           emit complete(response, success, m_i);
       }
       else emit moved();
       //}
       reply->deleteLater();
    }
}
*/

void ArtifactRequest::download(const QString &url)
{

    const QString queryUri = QString::fromLatin1("%1").arg(url);

    QUrl url_;
    url_.setEncodedUrl(url.toUtf8());

    qDebug()<<url_.toEncoded(QUrl::None);

    QNetworkRequest request(url_);

    QNetworkReply* reply = m_networkAccessManager->get(request);

    bool ok = connect(reply, SIGNAL(finished()), this, SLOT(onDownloadFinish()));
    Q_ASSERT(ok);
    Q_UNUSED(ok);
    connect(reply, SIGNAL(downloadProgress(qint64, qint64)), this, SIGNAL(downloadProgress(qint64, qint64)));
}

void ArtifactRequest::onDownloadFinish()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());

    QByteArray buffer;
    QString filename;
    bool success = false;
    if (reply) {
        if (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() >= 200 && reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() < 300) {
            const int available = reply->bytesAvailable();
            if (available > 0) {
                buffer = reply->readAll();
                filename = reply->rawHeader("Content-Disposition");
                filename = filename.mid(filename.indexOf("\"")+1);
                filename = filename.left(filename.length()-1);
                success = true;     //success settato solo se non ci sono errori e la risposta non è vuota
            }
        }else qDebug()<<reply->error() << " " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
        reply->deleteLater();
    }

    emit downloadComplete(buffer, filename, success);
}
