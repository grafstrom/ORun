using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ORunApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
    	var dv = Ui.loadResource(Rez.Strings.device);
    	if (dv.equals("fenix3")) {
            return [ new ORunFenix3() ];
    	}
    	else if (dv.equals("vivoactive")) {
            return [ new ORunVivoactive() ];
    	}
    	else if (dv.equals("fr920xt")) {
            return [ new ORunFr920xt() ];
    	}
    	else if (dv.equals("epix")) {
            return [ new ORunEpix() ];
    	}
    
        // Default ...
        return [ new ORunFenix3() ];
    }
}