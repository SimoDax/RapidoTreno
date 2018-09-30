/*
 * StatusRequest.cpp
 *
 *  Created on: 26/mar/2017
 *      Author: Simone
 */

#include <src/StatusRequest.hpp>

#define RICERCHE_FILE "./data/ricerche.dat"

using namespace bb::data;
using namespace bb::cascades;
using namespace bb::system;

StatusRequest::StatusRequest(QNetworkAccessManager * qnam, QVariantMap * statusData, QObject * parent) : QObject(parent)
{
    m_qnam = qnam;
    m_statusData = statusData;

}

void StatusRequest::requestStatusData(const QString &num)
{

    ArtifactRequest* requestStatus = new ArtifactRequest(m_qnam, this);
    bool ok = connect(requestStatus, SIGNAL(complete(QString, bool, int)), this, SLOT(onNumeroTrenoComplete(QString, bool, int)));
    Q_ASSERT(ok);
    Q_UNUSED(ok);

    m_num = num;

    requestStatus->requestArtifactline("http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/cercaNumeroTrenoTrenoAutocomplete/" + num);

}

void StatusRequest::onNumeroTrenoComplete(const QString &info, bool success, int i)
{
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if (success) {
        if (info.trimmed().isEmpty()) {
            emit badResponse("Treno non trovato");
            this->deleteLater();

        } else {
            QStringList numStaz = info.split("\n", QString::SkipEmptyParts);
            if (numStaz.isEmpty())
                return;
            if (numStaz.size() == 1) {
                numStaz = numStaz[0].split("-");

                ArtifactRequest* requestStatus = new ArtifactRequest(m_qnam, this);     //TODO: SI POTREBBE RICICLARE *request.. del maiale non si butta via niente (D.B.)
                bool ok = connect(requestStatus, SIGNAL(complete(QString, bool, int)), this, SLOT(onStatusDataComplete(QString, bool, int)));
                Q_ASSERT(ok);
                Q_UNUSED(ok);

                requestStatus->requestArtifactline("http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/andamentoTreno/" + numStaz[numStaz.size() - 1] + "/" + m_num);
            }
            else if (numStaz.size() > 1) {

                SystemListDialog* m_listdialog;
                m_listdialog = new SystemListDialog("Annulla");
                m_listdialog->setTitle("Seleziona treno interessato");
                m_listdialog->setDismissOnSelection(true);

                for (int i = 0; i < numStaz.size(); i++) {

                    QString textPart = numStaz[i].split("|")[0];
                    QString codePart = numStaz[i].split("|")[1];
                    QString code = codePart.split("-")[1];

                    if(!m_numStazList.contains(code)){

                        QString text = textPart.section("-", 1);
                        text.prepend(" da ");
                        text.prepend(textPart.section("-", 0, 0));

                        m_listdialog->appendItem(text);
                        m_numStazList.append(code);
                    }
                }
                bool success = connect(m_listdialog, SIGNAL(finished(bb::system::SystemUiResult::Type)), this, SLOT(onDialogFinished(bb::system::SystemUiResult::Type)));

                if (success)
                    m_listdialog->exec();
                else
                    m_listdialog->deleteLater();

            }

        }
        //emit stazioniLoaded();
    } else {
        /*m_errorMessage = info;
         m_error = true;
         emit statusChanged();*/
        emit badResponse(info);
        this->deleteLater();
    }

    request->deleteLater();
}

void StatusRequest::onStatusDataComplete(const QString &info, bool success, int i)
{
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if (success) {
        if (info.trimmed().isEmpty()) {
            emit badResponse("Nessun dato di tracciabilità disponibile per questo treno");
            //todo pezza per evitare i memory leak ma si potrebbe scrivere meglio tutta la funzione
            request->deleteLater();
            this->deleteLater();
            return;
        }
        parseStatusData(info);
        emit finished();

    } else
        emit badResponse(info);

    request->deleteLater();
    this->deleteLater();
}

void StatusRequest::parseStatusData(const QString& response)
{
    if (!m_statusData->isEmpty())
        m_statusData->clear();

    // Parse the json response with JsonDataAccess
    JsonDataAccess dataAccess;
    QVariantMap dati = dataAccess.loadFromBuffer(response).toMap();
    const QVariantList fermate = dati["fermate"].toList();
    dati["nFermate"] = fermate.size();

    m_statusData->unite(dati);

}

void StatusRequest::onDialogFinished(bb::system::SystemUiResult::Type result)
{
    if (result == bb::system::SystemUiResult::ItemSelection) {
        SystemListDialog *m_listdialog = qobject_cast<SystemListDialog*>(sender());
        QList<int> index = m_listdialog->selectedIndices();
        m_listdialog->deleteLater();
        if (index.size() == 1) {
            ArtifactRequest* requestStatus = new ArtifactRequest(m_qnam, this);
            bool ok = connect(requestStatus, SIGNAL(complete(QString, bool, int)), this, SLOT(onStatusDataComplete(QString, bool, int)));
            Q_ASSERT(ok);
            Q_UNUSED(ok);
            requestStatus->requestArtifactline("http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/andamentoTreno/" + m_numStazList[index[0]] + "/" + m_num);
        }
    } else {
        SystemListDialog *m_listdialog = qobject_cast<SystemListDialog*>(sender());
        m_listdialog->deleteLater();
        emit badResponse("Ricerca annullata");
    }
}

