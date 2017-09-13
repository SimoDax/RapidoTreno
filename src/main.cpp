#include <bb/cascades/Application>

#include <Qt/qdeclarativedebug.h>

#include "app.hpp"

using ::bb::cascades::Application;

Q_DECL_EXPORT int main(int argc, char** argv)
{
    Application app(argc, argv);

    App mainApp;

    return Application::exec();
}
