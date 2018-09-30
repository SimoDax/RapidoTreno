/*
 * NewsRequest.cpp
 *
 *  Created on: 30/apr/2017
 *      Author: Simone
 */

#include <src/NewsRequest.hpp>
#include <bb/data/XmlDataAccess>
#include <src/ArtifactRequest.hpp>

using namespace bb::data;

NewsRequest::NewsRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* newsPtr, QObject *parent = NULL) : QObject(parent)
{
    m_qnam = qnamPtr;
    m_news = newsPtr;
}

void NewsRequest::getNews(){

    ArtifactRequest* requestNews = new ArtifactRequest(m_qnam, this);
    bool ok = connect(requestNews, SIGNAL(complete(QString, bool, int)), this, SLOT(onFSNewsComplete(QString, bool, int)));
    Q_ASSERT(ok);
    Q_UNUSED(ok);

    //requestNews->requestArtifactline("http://www.fsnews.it/fsn/Infomobilit%C3%A0");   //old url
    requestNews->requestArtifactline("http://www.rfi.it/cms/v/index.jsp?vgnextoid=77f26c31d5611510VgnVCM1000008916f90aRCRD");

}

void NewsRequest::onFSNewsComplete(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());
            m_news->clear();
            if (success) {
                if (info.trimmed().isEmpty()){
                    emit badResponse("Errore nel caricamento delle notizie. Riprovare più tardi");
                    return;
                }
                //qDebug()<<info;
                QStringList eng;
                eng << "Jan" << "Feb" << "Mar" << "Apr" << "May" << "Jun" << "Jul" << "Aug" << "Sep" << "Oct" << "Nov" << "Dec";
                XmlDataAccess dataAccess;
                QVariantMap news = dataAccess.loadFromBuffer(info).toMap();

                foreach(const QVariant &news_, news["channel"].toMap()["item"].toList()){
                    QVariantMap _news_ = news_.toMap();
                    _news_["link"] = _news_["link"].toString().left(_news_["link"].toString().indexOf(" "));

                    //convert date in italian to parse it
                    _news_["pubDateEng"] = _news_["pubDate"];       //js stll needs the english date
                    for(int i =0; i<12; i++){
                        _news_["pubDate"]=_news_["pubDate"].toString().replace(eng[i], QDate::shortMonthName(i+1));
                    }
                    QDateTime t = QDateTime::fromString(_news_["pubDate"].toString().mid(5), "dd MMM yyyy hh:mm:ss 'GMT'");

                    //add timestamp field to order news list
                    _news_["timestamp"] = QString::number(t.toMSecsSinceEpoch());
                    //qDebug()<<_news_["pubDate"].toString().mid(5);
                    //qDebug()<<_news_["link"].toString().indexOf(" ");
                    m_news->insert(_news_);
                }

                /*  old url code
                QString _info = info.section("[{", 1, 1);
                _info = _info.section("}]", 0, 0);
                _info.prepend("[{");
                _info.append("}]");
                _info.squeeze();
                qDebug()<<"Info: "<<_info;
                // Parse the json response with JsonDataAccess
                   JsonDataAccess dataAccess;
                   const QVariantList news = dataAccess.loadFromBuffer(_info).toList();
                   m_news->clear();
                   if(news.size()>0){
                       int i = 0;
                   //m_news->setSortedAscending(false);
                   //m_news->setGrouping(bb::cascades::ItemGrouping::None);
                   foreach (const QVariant &news_, news) {
                       if(i<10){
                           QVariantMap _news_ = news_.toMap();
                           QDate d = QDate::fromString(_news_["data"].toString(), "dd.MM.yyyy");
                           _news_["sortingData"] = d.toString("yyyyMMdd");
                           //QVariant x = _news_["data"];
                           //_news_.remove("data");
                           //_news_.insert("ora", x);
                           m_news->insert(_news_);
                           i++;
                       }
                   }
                   }
                   else{
                       QVariantMap _news_;
                       QString titolo = "Nessuna notizia da mostrare al momento, riprovare pi&#249; tardi";
                       _news_["titolo"] = titolo.toLatin1();
                       _news_["data"]="";
                       _news_["luogo"]="";
                       _news_["azienda"]="";
                       _news_["link"]="";
                       m_news->insert(_news_);
                   }
                   //for(int k=0, s=soluzioni.size(), max=(s/2); k<max; k++) soluzioni.swap(k,s-(1+k));
                  */

                emit finished();

            } else {
                emit badResponse(info);
            }
            request->deleteLater();
            this->deleteLater();
}

