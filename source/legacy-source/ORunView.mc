using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

	const devSemiRound  = 1;
	const devVivoactive = 2;
	const devFenix3     = 3;
	const devEpix       = 4;
	const devFenix5     = 5;
	const devFenix6     = 6;
	const devFenix7     = 7;
	const devFr920      = 9;
	const vivoactive_hr = 10;

    var dev = devFenix3;

	var backcol;
	var forecol;
	var linecol;

	var distLabel;
	var paceLabel;
	var slbLabel;
	var sldLabel;
	var tmrLabel;
	var hbtLabel;
	var altLabel;
	
	var distConv;
	var unitConv;
	
	var heart;
	var speed;
	var dist;
	var tid;
	var startLap = 0;
	var startAlt;
	var startLoca;
	var loca;
	var alt;
	var lap = 1;
	
	var firstY     = 80;
	var firstYLbl  = 81;
	var firstYDat  = 96;
	var secondY    = 132;
	var secondYLbl = 164;
	var secondYDat = 131;
	var thirdY     = 185;
	var thirdYDat  = 189;
	
    var width = 218;
    var halfWitt;
	var middlew;
	var halfMiddleWitt;
    var topcenter;
    var botcenter;
	var altX;
	var tidX;
	var distX;
	var paceX;
	var todX;
	var battX;
	var slbX1;
	var slbX2;
	var slbY1;
	var slbY2;
	var sldX1;
	var sldX2;
	var sldY1;
	var sldY2;
	var topAlign1;
	var topAlign2;
	var topAlign3;
	var topAlign4;
	
    function onLayout(dc) {
    }

    function initialize() {
        DataField.initialize();
    
    	backcol = Gfx.COLOR_WHITE;
    	forecol = Gfx.COLOR_BLACK;
    	
    	// Inverted
    	backcol = Gfx.COLOR_BLACK;
    	forecol = Gfx.COLOR_WHITE;
    	
    	linecol = Gfx.COLOR_BLUE;
    	
    	slbLabel = Ui.loadResource(Rez.Strings.slb);
    	tmrLabel = Ui.loadResource(Rez.Strings.timer);
		paceLabel = Ui.loadResource(Rez.Strings.pace);
		distLabel = Ui.loadResource(Rez.Strings.dist);
		hbtLabel = Ui.loadResource(Rez.Strings.hbt);
		altLabel = Ui.loadResource(Rez.Strings.alt);
		
    	if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) {
    		sldLabel = Ui.loadResource(Rez.Strings.sld_ft);
    		unitConv = 1609;
    		distConv = 3.28084;
    	}
    	else {
    		sldLabel = Ui.loadResource(Rez.Strings.sld_m);
    		unitConv = 1000;
    		distConv = 1;
    	}
    	
    	initDevice();
    }
    
    function initDevice() {
    	var dv = Ui.loadResource(Rez.Strings.device);
        if (dv.equals("fenix5") ||
                 dv.equals("fenix5x")) {
            dev = devFenix5;
            firstY     = 80;
            firstYLbl  = 81;
            firstYDat  = 104;
            secondY    = 140;
            secondYLbl = 172;
            secondYDat = 142;
            thirdY     = 200;
            thirdYDat  = 202;
            calcXVals(240, -15, -20, 5, -5);
            return;
        }
        else if (dv.equals("vivoactive")) {
    	    dev = devVivoactive;
            firstY     = 45;
            firstYLbl  = 46;
            firstYDat  = 61;
            secondY    = 91;
            secondYLbl = 113;
            secondYDat = 90;
            thirdY     = 131;
            thirdYDat  = 132;
    	    calcXVals(205, -22, -15, 40, -32);
            return;
    	}
    	else if (dv.equals("fr920xt")) {
    	    dev = devFr920;
            firstY     = 45;
            firstYLbl  = 46;
            firstYDat  = 61;
            secondY    = 87;
            secondYLbl = 113;
            secondYDat = 90;
            thirdY     = 130;
            thirdYDat  = 132;
    	    calcXVals(205, -22, -15, 40, -32);
            return;
    	} else if (dv.equals("vivoactive_hr")) {
    	    dev = vivoactive_hr;
            firstY     = 65;
            firstYLbl  = 70;
            firstYDat  = 90;
            secondY    = 124;
            secondYLbl = 155;
            secondYDat = 128;
            thirdY     = 180;
            thirdYDat  = 182;
    	    calcXVals(148, -8, -15, 18, -18);
            return;
    	}
    	else if (dv.equals("epix")) {
    	    dev = devEpix;
            firstY     = 42;
            firstYLbl  = 43;
            firstYDat  = 57;
            secondY    = 87;
            secondYLbl = 110;
            secondYDat = 86;
            thirdY     = 130;
            thirdYDat  = 130;
    	    calcXVals(205, -22, -15, 40, -32);
            return;
    	}
    	else if (dv.equals("fr230") ||
    	         dv.equals("fr235") ||
    	         dv.equals("fr630") ||
    	         dv.equals("fr735xt")) {
    	    dev = devSemiRound;
            firstY     = 60;
            firstYLbl  = 61;
            firstYDat  = 77;
            secondY    = 110;
            secondYLbl = 139;
            secondYDat = 110;
            thirdY     = 160;
            thirdYDat  = 160;
    	    calcXVals(218, -15, -15, 7, -7);
            return;
    	}
    	
        // Default settings are for fenix 3
        calcXVals(218, -15, -15, 7, -7);
    }
    
	// adjust1 - X adjustment from middle of top vertical line
	// adjust2 - X adjustment from middle of bottom vertical line
	// adjust3 - X adjustment from bottom vertical for time-of-day
	// adjust4 - X adjustment from bottom vertical for battery pct
    function calcXVals(devWidth, adjust1, adjust2, adjust3, adjust4) {
	    width = devWidth;
	    
	    halfWitt = width / 2;
		middlew = width / 3;
		halfMiddleWitt = middlew / 2;
		altX = middlew + halfMiddleWitt;
		tidX = (halfWitt / 2) + 5;
		distX = (3 * halfWitt / 2) - 5;
		paceX = 2 * middlew + halfMiddleWitt;
	    topcenter = halfWitt + adjust1;
	    botcenter = halfWitt + adjust2;
		todX = botcenter + adjust3;
		battX = botcenter + adjust4;
		
		// Std align for round(ish) layout ...
		topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
		topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
		topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
		topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;

		if (dev == devFenix7) {
		    // Round watches ...
			slbX1 = topcenter - 7;
			slbY1 = 10;
			slbX2 = topcenter - 7;
			slbY2 = 30;
			sldX1 = topcenter + 7;
			sldY1 = 10;
			sldX2 = topcenter + 7;
			sldY2 = 30;
		}
		else if (dev == devFenix6) {
		    // Round watches ...
			slbX1 = topcenter - 7;
			slbY1 = 10;
			slbX2 = topcenter - 7;
			slbY2 = 37;
			sldX1 = topcenter + 7;
			sldY1 = 10;
			sldX2 = topcenter + 7;
			sldY2 = 37;
		}
		else if (dev == devFenix5) {
		    // Round watches ...
			slbX1 = topcenter - 10;
			slbY1 = 10;
			slbX2 = topcenter - 10;
			slbY2 = 37;
			sldX1 = topcenter + 10;
			sldY1 = 10;
			sldX2 = topcenter + 10;
			sldY2 = 37;
		}
		else if (dev == devFenix3) {
		    // Round watches ...
			slbX1 = topcenter - 10;
			slbY1 = 10;
			slbX2 = topcenter - 10;
			slbY2 = 20;
			sldX1 = topcenter + 10;
			sldY1 = 10;
			sldX2 = topcenter + 10;
			sldY2 = 20;
		}
		else if (dev == devSemiRound) {
		    // Semi-Round watches ...
			slbX1 = topcenter - 10;
			slbY1 = 0;
			slbX2 = topcenter - 10;
			slbY2 = 13;
			sldX1 = topcenter + 10;
			sldY1 = 0;
			sldX2 = topcenter + 10;
			sldY2 = 13;
		}
		else if (dev == vivoactive_hr) {
			// thin portrait rectangle watch
			slbX1 = 0;
			slbY1 = 0;
			slbX2 = topcenter - 9;
			slbY2 = 13;
			sldX1 = width - 2;
			sldY1 = 0;
			sldX2 = topcenter + 9;
			sldY2 = 13;
			topAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
		} else { // (dev == fr920xt) or other legacy square watches
		    // Square watches
			slbX1 = 0;
			slbY1 = 0;
			slbX2 = topcenter - 10;
			slbY2 = 5;
			sldX1 = width - 2;
			sldY1 = 0;
			sldX2 = topcenter + 10;
			sldY2 = 5;
			topAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
		}
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.
    
        heart = info.currentHeartRate;
        speed = info.currentSpeed;
        dist = info.elapsedDistance;
        tid = info.elapsedTime;
        
        if (info.currentLocation != null && lap > startLap) {
            startLoca = info.currentLocation;
            startAlt = info.altitude;
            startLap = lap;
        }
        
        if (info.altitude != null && startAlt != null) {
            alt = info.altitude - startAlt;
        }
        
        loca = info.currentLocation;
    }
    
    function onTimerStart() {
        lap++;
        Ui.requestUpdate();
    }
    
    function onTimerLap() {
        lap++;
        Ui.requestUpdate();
    }
    
    function getPace() {
		if (speed != null and speed >= 0.5) {
    		return fmt_num((unitConv / speed).toNumber());
    	}
    	return "0.0";
    }
    
    function fmt_num(num) {
        return (num / 60) + ":" + (num % 60).format("%02d");
    }
    
    function getDist() {
		if (dist != null) {
    		return (dist / unitConv).format("%0.2f");
    	}
    	return "0.00";
    }
    
    function getAlt() {
    
		if (alt != null) {
    		return (alt * distConv).toNumber();
    	}
    	return 0;
    }
    
    function getTid() {
    
    	if (tid != null) {
    		var totsec = tid / 1000;
    		var sec = totsec % 60;
    		var totmin = totsec / 60;
    		var min = totmin % 60;
    		var hour = totmin / 60;
    		
        	if (hour > 0) {
        		return Lang.format("$1$:$2$:$3$", [hour, min.format("%02d"), sec.format("%02d")]);
        	}
        	return Lang.format("$1$:$2$", [min.format("%02d"), sec.format("%02d")]);
    	}
    	return "00:00";
    }
    
    function getTod() {
    	var klokk = System.getClockTime();
        return Lang.format("$1$:$2$:$3$", [klokk.hour.format("%02d"), klokk.min.format("%02d"), klokk.sec.format("%02d")]);
    }
    
    function getBearing() {
    	if (startLoca != null and loca != null) {
    		return computeBearing(startLoca, loca).toString();
    	}
    	return "";
    }
    
    function getSld() {
    	if (startLoca != null and loca != null) {
    		return computeDistance(startLoca, loca).toString();
    	} 
    	return "";
    }
	
	function degrees(n) {
	  return n * (180 / Math.PI);
	}
	
	function atan2(y, x) {
		if (x > 0) {
			return Math.atan((y / x));
		}
		
		if (x < 0) {
			if (y >= 0) {
				return Math.atan((y / x)) + Math.PI;
			}
			return Math.atan((y / x)) - Math.PI;
		}
		
		if (y > 0) {
			return Math.PI / 2;
		}
		if (y < 0) {
			return -Math.PI / 2;
		}
		
		return 0.0;
	}
	
	function computeBearing(pos1, pos2) {
	
	    var startLat = pos1.toRadians()[0].toFloat();
	    var startLong = pos1.toRadians()[1].toFloat();
	    var endLat = pos2.toRadians()[0].toFloat();
	    var endLong = pos2.toRadians()[1].toFloat();
	
	    var dLong = endLong - startLong;

	    var dPhi = Math.ln(Math.tan(endLat/2.0+Math.PI/4.0)/Math.tan(startLat/2.0+Math.PI/4.0));

	    if (dLong > Math.PI) {
	        dLong = -(2.0 * Math.PI - dLong);
	    }
	    else if (dLong < -Math.PI) {
	        dLong = (2.0 * Math.PI + dLong);
	    }
	    
	    var calc = atan2(dLong, dPhi);
	    var deg = degrees(calc);
	    return (deg + 360.0).toNumber() % 360;
	}
	
	function computeDistance (pos1, pos2) {
	    var lat1, lat2, lon1, lon2, lat; //, lon; // lon not used
	    var dx, dy, distance;
	
	    lat1 = pos1.toDegrees()[0].toFloat();
	    lon1 = pos1.toDegrees()[1].toFloat();
	    lat2 = pos2.toDegrees()[0].toFloat();
	    lon2 = pos2.toDegrees()[1].toFloat();
	
	    lat = (lat1 + lat2) / 2 * 0.01745;
	    dx = 111.3 * Math.cos(lat) * (lon1 - lon2); 
	    dy = 111.3 * (lat1 - lat2);
	    distance = 1000 * Math.sqrt(dx * dx + dy * dy);
	    
	    return (distConv * distance).toNumber();
	}
	
	function setBatteryColor(dc, battery) {
        if (battery > 30) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        }
        else if (battery > 10) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
        }
        else {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
	}
	
    //! Handle the update event
    function onUpdate(dc) 
    {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        
        // Draw the BOLD lines 
        dc.drawLine( 0, firstY, width, firstY);         // Top horizontal 
        dc.drawLine( topcenter, firstY, topcenter, 0 ); // Top vertical split-line
        dc.drawLine( 0, thirdY, width, thirdY);         // Bottom horizontal 
        
        // Draw the thin middle lines 
        dc.setPenWidth(1);
        dc.drawLine( 0, secondY, width, secondY );                    // Middle horizontal 
        dc.drawLine( middlew, firstY, middlew, secondY );             // HR/Alt vertical split-line 
        dc.drawLine( 2 * middlew, firstY, 2 * middlew, secondY );     // Alt/Pace vertical split-line
        
        dc.drawLine( halfWitt, secondY, halfWitt, thirdY );           // Timer/Dist vertical split-line
        
        dc.drawLine( botcenter, thirdY, botcenter, dc.getHeight() );  // Battery/Time vertical split-line
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
		
        // ----------
        // TOP fields
        // ----------
        
        dc.drawText( slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, topAlign1 );
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), topAlign2 );
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, topAlign3 );
        dc.drawText( sldX2, sldY2, Gfx.FONT_NUMBER_MEDIUM, getSld(), topAlign4 );
        
        // -------------
        // MIDDLE fields
        // -------------
		var midfont = Gfx.FONT_LARGE;

        var hrString = (heart != null ? heart.toString() : "");
        dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( altX, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) {
        	dc.drawText( altX, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( altX, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        dc.drawText( paceX, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( paceX, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------
        
        dc.drawText( tidX, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( tidX, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( distX, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( distX, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------------
        // Bottom fields
        // -------------
        dc.drawText( todX, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
        var batt = Sys.getSystemStats().battery.toNumber();
        setBatteryColor(dc, batt);
        dc.drawText( battX, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);
	}
}


// using Toybox.WatchUi as Ui;
// using Toybox.Application as App;
// using Toybox.System as Sys;
// using Toybox.Time as Time;
// using Toybox.Activity as Act;
// using Toybox.Graphics as Gfx;

// class ORunView extends Ui.DataField {

// 	// mike note: following are UI settings to work with various dimensions of Garmin device - possibly better to use barrels and put these variables in separate device-specific file
// 	const devSemiRound  = 1;
// 	const devVivoactive = 2;
// 	const devFenix3     = 3;
// 	const devEpix       = 4;
// 	const devFenix5     = 5;
// 	const devFenix6     = 6;
// 	const devFenix7     = 7;
// 	const devFr920      = 9;

//     var dev = devFenix3; // mike note: default Fenix3 dimensions for UI arrangement

// 	// more device-specific dimensions values for UI arrangement
// 	var firstY     = 80;
// 	var firstYLbl  = 81;
// 	var firstYDat  = 96;
// 	var secondY    = 132;
// 	var secondYLbl = 164;
// 	var secondYDat = 131;
// 	var thirdY     = 185;
// 	var thirdYDat  = 189;
	
//     var width = 218;
//     var halfWitt;
// 	var middlew;
// 	var halfMiddleWitt;
//     var topcenter;
//     var botcenter;
	
// 	var slbX1;
// 	var slbX2;
// 	var slbY1;
// 	var slbY2;
// 	var sldX1;
// 	var sldX2;
// 	var sldY1;
// 	var sldY2;
// 	var topAlign1;
// 	var topAlign2;
// 	var topAlign3;
// 	var topAlign4;

// 	var altX;
// 	var tidX;
// 	var distX;
// 	var paceX;
// 	var todX;
// 	var battX;





// 	// mike note: ----------------------------- after this line variables are used for core functionality, NOT DEVICE SPECIFIC

// 	// mike note: other view variables - colors
// 	var backcol;
// 	var forecol;
// 	var linecol;

// 	// mike note: 
// 	var distLabel;
// 	var paceLabel;
// 	var slbLabel;
// 	var sldLabel;
// 	var tmrLabel;
// 	var hbtLabel;
// 	var altLabel;
	
// 	// mike note: conversion factor values for far-distance 'dist' for miles/km and short-distance 'unit' for feet/meters
// 	var distConv;
// 	var unitConv;
	
// 	// mike note: these variables updated in compute, and used in calculations for final view display updates
// 	var heart;
// 	var speed;
// 	var dist;
// 	var tid;

// 	var startLap = 0; // mike note: startLap is set to 0 upon run
// 	var startAlt;
// 	var startLoca;
// 	var loca;
// 	var alt;
// 	var lap = 1; // mike note: lap at 1 upon run
		
// 	// -------------------------------------------------------------------------------------------------------------------
//     function onLayout(dc) {
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
    
// 	function initialize() {  // mike note: initialize loads strings, get unit-settings
//         DataField.initialize();
    
//     	backcol = Gfx.COLOR_WHITE;										// mike note: unnecessary initialization of color settings
//     	forecol = Gfx.COLOR_BLACK;										// mike note: these two statements could probably be removed
    	
//     	// Inverted
//     	backcol = Gfx.COLOR_BLACK;										// mike note: initialize color settings
//     	forecol = Gfx.COLOR_WHITE;
    	
//     	linecol = Gfx.COLOR_BLUE;
    	
//     	slbLabel = Ui.loadResource(Rez.Strings.slb);					// mike note: load strings for datafield labels
//     	tmrLabel = Ui.loadResource(Rez.Strings.timer);
// 		paceLabel = Ui.loadResource(Rez.Strings.pace);
// 		distLabel = Ui.loadResource(Rez.Strings.dist);
// 		hbtLabel = Ui.loadResource(Rez.Strings.hbt);
// 		altLabel = Ui.loadResource(Rez.Strings.alt);
		
//     	if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) { // mike note: update conversion factor to miles/feet
//     		sldLabel = Ui.loadResource(Rez.Strings.sld_ft);
//     		unitConv = 1609;
//     		distConv = 3.28084;
//     	}
//     	else { 													 // mike note: update conversion factor to kilometers/meters
//     		sldLabel = Ui.loadResource(Rez.Strings.sld_m);
//     		unitConv = 1000;
//     		distConv = 1;
//     	}
    	
//     	initDevice();
//     }
//     // -------------------------------------------------------------------------------------------------------------------




























//     function initDevice() {
// 		System.println("running initialization for sizing");

//     	var dv = Ui.loadResource(Rez.Strings.device);
//         if (dv.equals("fenix7x")) {
// 					   dev = devFenix7;
// 					   setDeviceLayout(100, 101, 120, 170, 220, 180, 242, 250);
// 			calcXVals(280, -15, -15, 7, -7);
//             return;
//         }
//         else if (dv.equals("fenix7") ||
//                  dv.equals("fenix6") ||
//                  dv.equals("fenix6pro")) {
// 					   dev = devFenix6;
// 					   setDeviceLayout(105, 110, 124, 170, 206, 172, 228, 230);
// 			calcXVals(260, -15, -15, 7, -7);
//             return;
//         }
//         else if (dv.equals("fenix6xpro")) {
// 					   dev = devFenix6;
// 					   setDeviceLayout(110, 115, 130, 180, 220, 182, 246, 248);
// 			calcXVals(280, -10, -15, 7, -7);
//             return;
//         }
//         else if (dv.equals("fenix5") ||
//                  dv.equals("fenix5x")) {
// 					   dev = devFenix5;
// 					   setDeviceLayout(80, 81, 104, 140, 172, 142, 200, 202);
// 			calcXVals(240, -15, -20, 5, -5);
//             return;
//         }
//         else if (dv.equals("vivoactive")) {
// 				   dev = devVivoactive;
// 				   setDeviceLayout(45, 46, 61, 91, 113, 90, 131, 132);
// 		     calcXVals(205, -22, -15, 40, -32);
//             return;
//     	}
//     	else if (dv.equals("fr920xt")) {
// 				   dev = devFr920;
// 				   setDeviceLayout(45, 46, 61, 87, 113, 90, 130, 132);
// 		     calcXVals(205, -22, -15, 40, -32);
//             return;
//     	}
//     	else if (dv.equals("epix")) {
// 				   dev = devEpix;
// 				   setDeviceLayout(42, 43, 57, 87, 110, 86, 130, 130);
// 		     calcXVals(205, -22, -15, 40, -32);
//             return;
//     	}
//     	else if (dv.equals("fr230") ||
//     	         dv.equals("fr235") ||
//     	         dv.equals("fr630") ||
//     	         dv.equals("fr735xt")) {
// 				   dev = devSemiRound;
// 				   setDeviceLayout(60, 61, 77, 110, 139, 110, 160, 160);
// 		     calcXVals(218, -15, -15, 7, -7);
//             return;
//     	}
    	
//         // Default settings are for fenix 3
// 		dev = devFenix3;
// 		setDeviceLayout(80, 81, 96, 132, 164, 131, 185, 189);
// 	 calcXVals(218, -15, -15, 7, -7);
//     }
//     // -------------------------------------------------------------------------------------------------------------------
// 	function setDeviceLayout(y1, yl1, yd1, y2, yl2, yd2, y3, yd3) {
// 		firstY = y1;
// 		firstYLbl = yl1;
// 		firstYDat = yd1;
// 		secondY = y2;
// 		secondYLbl = yl2;
// 		secondYDat = yd2;
// 		thirdY = y3;
// 		thirdYDat = yd3;
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------

// 	// adjust1 - X adjustment from middle of top vertical line
// 	// adjust2 - X adjustment from middle of bottom vertical line
// 	// adjust3 - X adjustment from bottom vertical for time-of-day
// 	// adjust4 - X adjustment from bottom vertical for battery pct

//     function calcXVals(devWidth, adjust1, adjust2, adjust3, adjust4) {
// 	    width = devWidth;
	    
// 	    halfWitt = width / 2;
// 		middlew = width / 3;
// 		halfMiddleWitt = middlew / 2;
// 		altX = middlew + halfMiddleWitt;
// 		tidX = (halfWitt / 2) + 5;
// 		distX = (3 * halfWitt / 2) - 5;
// 		paceX = 2 * middlew + halfMiddleWitt;
// 	    topcenter = halfWitt + adjust1;
// 	    botcenter = halfWitt + adjust2;
// 		todX = botcenter + adjust3;
// 		battX = botcenter + adjust4;
		
// 		// Std align for round(ish) layout ...
// 		topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
// 		topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
// 		topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
// 		topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;

// 		if (dev == devFenix7) {
// 		    // Round watches ...
// 			setRoundTop(7, 10, 30);
// 		}
// 		else if (dev == devFenix6) {
// 		    // Round watches ...
// 			setRoundTop(7, 10, 37);
// 		}
// 		else if (dev == devFenix5) {
// 		    // Round watches ...
// 			setRoundTop(10, 10, 37);
// 		}
// 		else if (dev == devFenix3) {
// 		    // Round watches ...
// 			setRoundTop(10, 10, 20);
// 		}
// 		else if (dev == devSemiRound) {
// 		    // Semi-Round watches ...
// 			setRoundTop(10, 0, 13);
// 		}
// 		else {
// 		    // Square watches ...
// 			slbX1 = 0;
// 			slbY1 = 0;
// 			slbX2 = topcenter - 10;
// 			slbY2 = 5;
// 			sldX1 = width - 2;
// 			sldY1 = 0;
// 			sldX2 = topcenter + 10;
// 			sldY2 = 5;
// 			topAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
// 			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
// 			topAlign3 = Gfx.TEXT_JUSTIFY_RIGHT;
// 			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
// 		}
//     }
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function setRoundTop(offset, y1, y2) {
// 		slbX1 = topcenter - offset;
// 		slbY1 = y1;
// 		slbX2 = topcenter - offset;
// 		slbY2 = y2;
// 		sldX1 = topcenter + offset;
// 		sldY1 = y1;
// 		sldX2 = topcenter + offset;
// 		sldY2 = y2;
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
    
	



























// 	//! The given info object contains all the current workout
//     //! information. Calculate a value and return it in this method.
//     function compute(info) {
//         // See Activity.Info in the documentation for available information.
    
// 		// mike note: compute updates heart, speed, dist, tid (elapsed time), startLoca (currentLocation), startAlt (altitude), lap, alt (altitude), Loca (currentLocation)

//         heart = info.currentHeartRate;
//         speed = info.currentSpeed;
//         dist = info.elapsedDistance;
//         tid = info.elapsedTime;
        
//         if (info.currentLocation != null && lap > startLap) {
//             startLoca = info.currentLocation;
//             startAlt = info.altitude;
//             startLap = lap;
// 			System.println("  compute: lap is now " + lap);
//         }
        
//         if (info.altitude != null && startAlt != null) {
//             alt = info.altitude - startAlt;
//         }
        
//         loca = info.currentLocation;
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function onTimerStart() { // mike note: increment lap when user presses start, which is interesting to me
//         lap++;
// 		System.println("  user pressed Start: lap is now " + lap);
//         Ui.requestUpdate();
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function onTimerLap() { // mike note: increment lap when user presses lap
//         lap++;
// 		System.println("  user pressed Lap:   lap is now " + lap);
//         Ui.requestUpdate();
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getPace() { // mike note: simple method returns pace with unit conversion  (runs with elapsed time as argument)
// 		if (speed != null and speed >= 0.5) {
//     		return fmt_num((unitConv / speed).toNumber());
//     	}
//     	return "0.0";
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function fmt_num(num) { // formats time into minutes + seconds for display
//         return (num / 60) + ":" + (num % 60).format("%02d");
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getDist() { // mike note: get unit-converted distance string
// 		if (dist != null) {
//     		return (dist / unitConv).format("%0.2f");
//     	}
//     	return "0.00";
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getAlt() { // mike note: get altitude, converted for units
    
// 		if (alt != null) {
//     		return (alt * distConv).toNumber();
//     	}
//     	return 0;
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getTid() { // mike note: get the elapsed activity time in MM:SS or HH:MM:SET format
    
//     	if (tid != null) {
//     		var totsec = tid / 1000;
//     		var sec = totsec % 60;
//     		var totmin = totsec / 60;
//     		var min = totmin % 60;
//     		var hour = totmin / 60;
    		
//         	if (hour > 0) {
//         		return Lang.format("$1$:$2$:$3$", [hour, min.format("%02d"), sec.format("%02d")]);
//         	}
//         	return Lang.format("$1$:$2$", [min.format("%02d"), sec.format("%02d")]);
//     	}
//     	return "00:00"; // return "00:00" if elapsed timer is null
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getTod() { // mike note: get the Time of day
//     	var klokk = System.getClockTime();
//         return Lang.format("$1$:$2$:$3$", [klokk.hour.format("%02d"), klokk.min.format("%02d"), klokk.sec.format("%02d")]);
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getBearing() { // mike note: safety wrapper for computeBearing // this could be best, although other ways exist to do this
//     	if (startLoca != null and loca != null) {
//     		return computeBearing(startLoca, loca).toString();
//     	}
//     	return ""; //  mike note: returns string
//     }
//     // -------------------------------------------------------------------------------------------------------------------
//     function getSld() { // mike note: safety wrapper for computeBearing // this could be best, although other ways exist to do this
//     	if (startLoca != null and loca != null) {
//     		return computeDistance(startLoca, loca).toString();
//     	} 
//     	return ""; //  mike note: returns string
//     }
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function degrees(n) { // mike note: newer models on Garmin have this built-in function in Math library I believe
// 	  return n * (180 / Math.PI);
// 	} // mike note: returns degrees
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function atan2(y, x) { // mike note: this function has historically been troublesome when garmin updates its backend firmware, check on atan2 vs log vs logn (ln)
// 		if (x > 0) {
// 			return Math.atan((y / x));
// 		}
		
// 		if (x < 0) {
// 			if (y >= 0) {
// 				return Math.atan((y / x)) + Math.PI;
// 			}
// 			return Math.atan((y / x)) - Math.PI;
// 		}
		
// 		if (y > 0) {
// 			return Math.PI / 2;
// 		}
// 		if (y < 0) {
// 			return -Math.PI / 2;
// 		}
		
// 		return 0.0; // mike note: returns degrees
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function computeBearing(pos1, pos2) { // mike note: rhumb line bearing (constant bearing, meaning it crosses all meridians of longitude at same angle)
	
// 	    var startLat = pos1.toRadians()[0].toFloat();
// 	    var startLong = pos1.toRadians()[1].toFloat();
// 	    var endLat = pos2.toRadians()[0].toFloat();
// 	    var endLong = pos2.toRadians()[1].toFloat();
	
// 	    var dLong = endLong - startLong;

// 	    var dPhi = Math.log(Math.tan(endLat/2.0+Math.PI/4.0)/Math.tan(startLat/2.0+Math.PI/4.0), 10);

// 	    if (dLong > Math.PI) {
// 	        dLong = -(2.0 * Math.PI - dLong);
// 	    }
// 	    else if (dLong < -Math.PI) {
// 	        dLong = (2.0 * Math.PI + dLong);
// 	    }
	    
// 	    var calc = atan2(dLong, dPhi);
// 	    var deg = degrees(calc);
// 	    return (deg + 360.0).toNumber() % 360;
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function computeDistance (pos1, pos2) { // mike note: calculate distance using Equirectangular Projection (flat-surface) approximation, best suited for orienteering or close distances
// 	    var lat1, lat2, lon1, lon2, lat, lon; // mike note: last var lon is unused, could be deleted
// 	    var dx, dy, distance;
	
// 	    lat1 = pos1.toDegrees()[0].toFloat();
// 	    lon1 = pos1.toDegrees()[1].toFloat();
// 	    lat2 = pos2.toDegrees()[0].toFloat();
// 	    lon2 = pos2.toDegrees()[1].toFloat();
	
// 	    lat = (lat1 + lat2) / 2 * 0.01745;
// 	    dx = 111.3 * Math.cos(lat) * (lon1 - lon2); 
// 	    dy = 111.3 * (lat1 - lat2);
// 	    distance = 1000 * Math.sqrt(dx * dx + dy * dy);
	    
// 	    return (distConv * distance).toNumber();
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
// 	function setBatteryColor(dc, battery) { // mike note: change color of battery % if over 30%, over 10%
//         if (battery > 30) {
//             dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
//         }
//         else if (battery > 10) {
//             dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
//         }
//         else {
//             dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
//         }
// 	}
// 	// -------------------------------------------------------------------------------------------------------------------
//     //! Handle the update event
//     function onUpdate(dc) 
//     {
//         dc.setColor(Gfx.COLOR_WHITE, backcol);
//         dc.clear(); // paint background color
        
//         dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
//         dc.setPenWidth(3); // set foreground color linecol for printing lines, text
        
//         // Draw the BOLD lines 
//         dc.drawLine( 0, firstY, width, firstY);         // Top horizontal 
//         dc.drawLine( topcenter, firstY, topcenter, 0 ); // Top vertical split-line
//         dc.drawLine( 0, thirdY, width, thirdY);         // Bottom horizontal 
        
//         // Draw the thin middle lines 
//         dc.setPenWidth(1);
//         dc.drawLine( 0, secondY, width, secondY );                    // Middle horizontal 
//         dc.drawLine( middlew, firstY, middlew, secondY );             // HR/Alt vertical split-line 
//         dc.drawLine( 2 * middlew, firstY, 2 * middlew, secondY );     // Alt/Pace vertical split-line
        
//         dc.drawLine( halfWitt, secondY, halfWitt, thirdY );           // Timer/Dist vertical split-line
        
//         dc.drawLine( botcenter, thirdY, botcenter, dc.getHeight() );  // Battery/Time vertical split-line
//         dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
		
//         // ---------- ////////////////////////////////////
//         // TOP fields ////////////////////////////////////
//         // ---------- ////////////////////////////////////
        
// 		// mike note: top left - Deg / slb - degrees bearing (in RED medium font)
//         dc.drawText( slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, topAlign1 );
//         dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
//         dc.drawText( slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), topAlign2 );
        
// 		// mike note: top right - SLD straight-line distance in ft or m (in med font)
// 		dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
//         dc.drawText( sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, topAlign3 );
//         dc.drawText( sldX2, sldY2, Gfx.FONT_NUMBER_MEDIUM, getSld(), topAlign4 );
        
//         // ------------- ////////////////////////////////////
//         // MIDDLE fields ////////////////////////////////////
//         // ------------- ////////////////////////////////////
// 		var midfont = Gfx.FONT_LARGE;

// 		// mike note: middle left - heart rate in bpm
//         var hrString = (heart != null ? heart.toString() : "");
//         dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
//         dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
// 		// mike note: middle center - altitude with unit conversion
//         dc.drawText( altX, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
//         var altNum = getAlt();
//         if (altNum > 9999) { // mike note: if elevation over 9999 (10k ft or m?), use smaller font (med instead of large)
//         	dc.drawText( altX, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
//         }
//         else {
//         	dc.drawText( altX, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
//         }
        
// 		// mike note: middle right - pace with unit conversion
//         dc.drawText( paceX, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
//         dc.drawText( paceX, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER ); 					
        
//         // ------- // mike note: lower half of middle fields 
        
// 		// mike note: lower middle left - elapsed activity time, formatted
//         dc.drawText( tidX, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
//         dc.drawText( tidX, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
// 		// mike note: lower middle right - converted activity distance total (does not reset upon new lap)
//         dc.drawText( distX, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
//         dc.drawText( distX, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
//         // ------------- ////////////////////////////////////
//         // Bottom fields ////////////////////////////////////
//         // ------------- ////////////////////////////////////
        
// 		// mike note: time of day HH:MM:SS
// 		dc.drawText( todX, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
// 		// mike note: battery percentage, writing in different color depending upon percentage
//         var batt = Sys.getSystemStats().battery.toNumber();
//         setBatteryColor(dc, batt);
//         dc.drawText( battX, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);

// 		System.println(memstr());    
// 	}
// 	function memstr () { return ((Toybox.System.getSystemStats().freeMemory.toFloat()/Toybox.System.getSystemStats().totalMemory.toFloat()) * 100).toNumber() + "% available"; } 

// }