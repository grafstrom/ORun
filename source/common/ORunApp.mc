using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ORunApp extends App.AppBase {

    //! Initialize the Connect IQ application base class.
    function initialize() {
        AppBase.initialize();
    }

    //! Create and return the shape-specific view selected by the build target.
    function getInitialView() {
        // Default ...
        return [ new ORunView() ];
    }
}