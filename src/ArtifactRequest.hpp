#ifndef ARTIFACTREQUEST_HPP
#define ARTIFACTREQUEST_HPP

#include <QtCore/QObject>

//this class makes the web requests

class ArtifactRequest : public QObject
{
    Q_OBJECT

public:
    ArtifactRequest(QNetworkAccessManager* networkAccessManager, QObject *parent, int i = -1);

    void requestArtifactline(const QString &url);
    void download(const QString &url);
    void post(const QString &url, const QByteArray &postData);

Q_SIGNALS:

    void complete(const QString &info, bool success, int i);
    void downloadComplete(QByteArray &info, QString filename, bool success);
    void moved();
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);


private Q_SLOTS:

    void onArtifactlineReply();
    void onPostReply();
    void onDownloadFinish();


private:
    QNetworkAccessManager* m_networkAccessManager;
    int m_i;
};


#endif
