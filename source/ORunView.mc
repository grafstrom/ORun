using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

	const devFenix3     = 1;
	const devVivoactive = 2;
	const devFr920      = 3;
	const devEpix       = 4;
	const devFr230      = 5;

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
    	if (dv.equals("vivoactive")) {
    	    dev = devVivoactive;
            firstY     = 45;
            firstYLbl  = 46;
            firstYDat  = 61;
            secondY    = 91;
            secondYLbl = 113;
            secondYDat = 90;
            thirdY     = 131;
            thirdYDat  = 132;
    	    calcXVals(205, -22, -15, 40, -32, 0);
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
    	    calcXVals(205, -22, -15, 40, -32, 0);
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
    	    calcXVals(205, -22, -15, 40, -32, 0);
            return;
    	}
    	
    	// Default settings are for fenix 3
    	calcXVals(218, -15, -15, 7, -7, 10);
    }
    
    function calcXVals(devWidth, adjust1, adjust2, adjust3, adjust4, topY) {
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
		
		if (topY == 0) {
		    // Square watches ...
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
		else {
		    // Round watches ...
			slbX1 = topcenter - 10;
			slbY1 = 10;
			slbX2 = topcenter - 10;
			slbY2 = 20;
			sldX1 = topcenter + 10;
			sldY1 = 10;
			sldX2 = topcenter + 10;
			sldY2 = 20;
			topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
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
	
	    var dPhi = Math.log(Math.tan(endLat/2.0+Math.PI/4.0)/Math.tan(startLat/2.0+Math.PI/4.0));
	    
	    
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
	    var lat1, lat2, lon1, lon2, lat, lon;
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