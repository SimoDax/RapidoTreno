APP_NAME = RapidoTreno

CONFIG += qt warn_on cascades10

LIBS += -lbbsystem
LIBS += -lbbdata
LIBS += -lbb
LIBS += -lQtLocationSubset

QT += network

include(config.pri)
