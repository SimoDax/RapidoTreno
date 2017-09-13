#ifndef APP_HPP
#define APP_HPP

#include "ArtifactRequest.hpp"
#include "TrainRequest.hpp"
#include "ItaloRequest.hpp"

#include <bb/cascades/GroupDataModel>
#include <bb/cascades/ArrayDataModel>
#include <bb/cascades/AbstractPane>
#include <bb/system/SystemListDialog>
#include <bb/system/SystemUiResult>
#include <bb/system/InvokeManager>

#include <QtCore/QObject>
#include <QtCore/QMap>

//! [0]
class App : public QObject
{
    Q_OBJECT

    //Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool error READ error NOTIFY statusChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY statusChanged)
    Q_PROPERTY(bool pend READ pend NOTIFY pendChanged)
    Q_PROPERTY(bool loggedIn READ loggedIn)

    Q_PROPERTY(bb::cascades::DataModel* model READ model CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* stazioni READ stazioni CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* ricerche READ ricerche CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* news READ news CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* solutionDetails READ solutionDetails CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* stazioneStatus READ stazioneStatus CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* tickets READ tickets CONSTANT)
    Q_PROPERTY(QVariantMap statusData READ statusData CONSTANT)
    Q_PROPERTY(QVariantMap profileData READ profileData CONSTANT)


public:
    App(QObject *parent = 0);

public Q_SLOTS:
    //void caricaStazioni(const QString &iniz);
    void requestArtifact(const QString &da, const QString &a, const QString &dt, const QString &adulti, const QString &bambini, const QString &frecce, bool italo, bool silent);

    void requestStatusData(const QString &num);

    void requestStatusDataItalo(const QString &num);

    void requestNews();

    void requestFSNews();

    void requestStation(QString num);

    void requestAreaPers(QString user, QString pass);

    void openTicket(const QString &id, const QString &tsid);
    //void startAsyncLoad();

    void setSolutionDetailsModel(const QVariantList indexPath);

    Q_INVOKABLE QVariant requestStatusField(const QString &field, const int &field2, const QString &field3);
    Q_INVOKABLE QVariant requestStatusField(const QString &field, const int &field2);
    Q_INVOKABLE QVariant requestStatusField(const QString &field);

    //void salvaPref(QVariant data);

    //bool isPref(const QVariantList indexPath);

    //void caricaPref();

    void salvaEvento(const QVariantList indexPath);

    void saveSetting(const QString &key, const QVariant &value);

    QVariant loadSetting(const QString &key);
    /*
     * Allows the QML to reset the state of the application
     */
    void reset();

    void resetStazioni();

    void salvaRicerca(QString num);

    void caricaRicerche();

    void clearPreloaded();

    void pagah(const QVariantList indexPath);

    void switchPend(const QString &part, const QString &arr);

    /**
     * Called to get date string from a timestamp.
     */
    Q_INVOKABLE QString dateFromTimestamp(const QString &timestamp);

Q_SIGNALS:
    /*
     * This signal is emitted whenever the artifacts have been loaded successfully
     */
    void artifactsLoaded();
    void stazioniLoaded();
    void statusDataLoaded();
    void newsLoaded();
    void profileLoaded();
    /*
     * The change notification signals of the properties
     */
    //void activeChanged();
    void statusChanged();

    void pendChanged();

    void pendToast();

    void badResponse(QString errorMessage);

    void abort();

    void displayWait();

    void showDetails();

    void removeWait();

    void openChanged();

    //void ricercheLoaded();

private Q_SLOTS:


    //void onStazComplete(const QString &info, bool success);

    //void onNumeroTrenoComplete(const QString &info, bool success);

    //void onStatusDataComplete(const QString &info, bool success);

    void onNewsComplete(const QString &info, bool success);

    void onFSNewsComplete(const QString &info, bool success, int i);

    //void onDialogFinished(bb::system::SystemUiResult::Type result);

    //void parseItaloTracking(const QString& _response, bool success);

private:


    //void parseStazioni(const QString& response);

    //void parseStatusData(const QString& response);

    //static bool lessThan(QVariantList l1, QVariantList l2);

    //void parseNews(const QString& response);

    /*
     * The accessor methods of the properties
     */
    //bool active() const;
    bool error() const;
    QString errorMessage() const;
    bool pend() const;
    bool loggedIn();
    bb::cascades::DataModel* model() const;
    bb::cascades::DataModel* stazioni() const;
    bb::cascades::DataModel* ricerche() const;
    bb::cascades::DataModel* news() const;
    bb::cascades::DataModel* solutionDetails() const;
    bb::cascades::DataModel* stazioneStatus() const;
    bb::cascades::DataModel* tickets() const;
    QVariantMap statusData() const;
    QVariantMap profileData() const;
    //QList<QList<QMap>>* preloaded() const;

private:
    bool m_active, m_error, m_pend, m_logged;
    QString m_errorMessage;
    bb::cascades::GroupDataModel* m_model;
    bb::cascades::GroupDataModel* m_stazioni;
    bb::cascades::GroupDataModel* m_news;
    bb::cascades::GroupDataModel* m_solutionDetails;
    bb::cascades::GroupDataModel* m_stazioneStatus;
    bb::cascades::GroupDataModel* m_tickets;
    bb::cascades::ArrayDataModel* m_ricerche;
    //bb::cascades::ArrayDataModel* m_stazioni;
    bb::cascades::AbstractPane* root;
    QVariantMap* m_statusData;
    QString m_num;
    //QStringList m_numStazList;
    QList<QVariantList>* m_preloaded;
    static const QString m_filePath;
    static const QString m_prefPath;
    static const QString m_stazioniPath;
    static const QString m_dumpStazioniPath;
    QString m_adulti;
    QString m_bambini;
    QNetworkAccessManager * m_qnam;
    QVariantMap* m_profile;
};


#endif
