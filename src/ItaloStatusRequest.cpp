/*
 * ItaloStatusRequest.cpp
 *
 *  Created on: 28/mar/2017
 *      Author: Simone
 */

#include <src/ItaloStatusRequest.hpp>

ItaloStatusRequest::ItaloStatusRequest(QNetworkAccessManager * qnam, QVariantMap * statusData, QObject * parent) : QObject(parent)
{
    m_qnam = qnam;
    m_statusData = statusData;
}

void ItaloStatusRequest::requestStatusData(const QString &num)
{

    ArtifactRequest* requestStatus = new ArtifactRequest(m_qnam, this);
    bool ok = connect(requestStatus, SIGNAL(complete(QString, bool, int)), this, SLOT(onStatusDataComplete(QString, bool, int)));
    Q_ASSERT(ok);
    Q_UNUSED(ok);

    m_num = num;

    requestStatus->requestArtifactline("https://italoinviaggio.italotreno.it/SiteCore/IT/italo/Pagine/default.aspx");

}

void ItaloStatusRequest::onStatusDataComplete(const QString &info, bool success, int i)
{

    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if (!m_statusData->isEmpty())
        m_statusData->clear();

    if (!success || info.trimmed().isEmpty() || !info.contains(m_num))
        emit badResponse("Treno non trovato");

    else {

        int begin = info.lastIndexOf(m_num);
        QString response = info.mid(begin);
        parseStatusData(response);

        emit finished();
    }

    this->deleteLater();        //NOTE: *request is child of this class so it will be deleted with her father. No mem leakes here :)
}

void ItaloStatusRequest::parseStatusData(QString& response)
{     //TODO: no error handling

    QVariantMap status;

    response.replace("&nbsp;&nbsp;", "");
    response.replace("&nbsp;", " ");

    status["numTreno"] = response.mid(0, response.indexOf("<"));

    //qDebug()<<response.indexOf("</span>");

    int beginNext = response.indexOf("<span class='evidenza'>") + 23;
    status["info"] = response.mid(beginNext, response.indexOf("</span>", beginNext) - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["next"] = response.mid(beginNext, response.indexOf("</strong>") - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["binarioNext"] = response.mid(beginNext, response.indexOf("</strong>", beginNext) - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["arrivoProg"] = response.mid(beginNext, response.indexOf("</strong>", beginNext) - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["arrivoEff"] = response.mid(beginNext, response.indexOf("</strong>", beginNext) - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["partenzaProg"] = response.mid(beginNext, response.indexOf("</strong>", beginNext) - beginNext);

    beginNext = response.indexOf("<strong>", beginNext) + 8;
    status["partenzaEff"] = response.mid(beginNext, response.indexOf("</strong>", beginNext) - beginNext);

    beginNext = response.indexOf("<span class='evidenza'>", beginNext) + 23;
    status["stato"] = response.mid(beginNext, response.indexOf("</span>", beginNext) - beginNext);

    m_statusData->unite(status);
}
