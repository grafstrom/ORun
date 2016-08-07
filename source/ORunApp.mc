using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ORunApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }
    
    function initialize() {
        AppBase.initialize();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        // Default ...
        return [ new ORunView() ];
    }
}