using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunBase extends Ui.DataField {

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
	var alt;
	var tid;
	var startLoca;
	var loca;
	
    function onLayout(dc) {
    }

    function initialize() {
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
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.
    
        heart = info.currentHeartRate;
        speed = info.currentSpeed;
        dist = info.elapsedDistance;
        tid = info.elapsedTime;
        alt = info.altitude;
        
        if (info.startLocation != null) {
        	startLoca = info.startLocation;
        }
        loca = info.currentLocation;
        
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
}

class ORunFenix3 extends ORunBase {

	const firstY     = 80;
	const firstYLbl  = 81;
	const firstYDat  = 96;
	const secondY    = 132;
	const secondYLbl = 164;
	const secondYDat = 131;
	const thirdY     = 185;
	const thirdYDat  = 189;

    function initialize() {
        ORunBase.initialize();
    }
    
    //! Handle the update event
    function onUpdate(dc)
    {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        var width = dc.getWidth();
        var halfWitt = width / 2;
        var topcenter = halfWitt - 15;
        var botcenter = halfWitt - 15;
		var middlew = width / 3;
		var halfMiddleWitt = middlew / 2;
        
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
        dc.drawText( topcenter - 10, 10, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_RIGHT); 
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( topcenter - 10, 20, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT );
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( topcenter + 10, 10, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_LEFT );
        dc.drawText( topcenter + 10, 20, Gfx.FONT_NUMBER_MEDIUM, getSld(), Gfx.TEXT_JUSTIFY_LEFT );
        
        // -------------
        // MIDDLE fields
        // -------------
		var midfont = Gfx.FONT_LARGE;

        var hrString = (heart != null ? heart.toString() : "");
        dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) {
        	dc.drawText( middlew + halfMiddleWitt, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( middlew + halfMiddleWitt, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------
        
        dc.drawText( (halfWitt / 2) + 5, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (halfWitt / 2) + 5, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( (3 * halfWitt / 2) - 5, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (3 * halfWitt / 2) - 5, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------------
        // Bottom fields
        // -------------
        dc.drawText( botcenter + 7, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
        var batt = Sys.getSystemStats().battery.toNumber();
        ORunBase.setBatteryColor(dc, batt);
        dc.drawText( botcenter - 7, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);
	}
}	
	
class ORunVivoactive extends ORunBase {

    function initialize() {
        ORunBase.initialize();
    }

    function onUpdate(dc)
    {
        // Vivoactive apparently does not support a 'full screen' data-field :-(
        // ... so we just display bearing and Straight-Line-Distance.
    
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        var width = dc.getWidth();
        var halfWitt = width / 2;
        var topcenter = halfWitt - 22;
        
        dc.drawLine( topcenter, 80, topcenter, 0 );
        
        dc.setPenWidth(1);
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        
        // ----------
        // TOP fields
        // ----------
        dc.drawText( 0, 0, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_LEFT); 
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( topcenter - 10, 5, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT );
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( width - 2, 0, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_RIGHT );
        dc.drawText( topcenter + 10, 5, Gfx.FONT_NUMBER_MEDIUM, getSld(), Gfx.TEXT_JUSTIFY_LEFT );
    }
}

class ORunEpix extends ORunBase {

	const firstY     = 42;
	const firstYLbl  = 43;
	const firstYDat  = 57;
	const secondY    = 87;
	const secondYLbl = 110;
	const secondYDat = 86;
	const thirdY     = 130;
	const thirdYDat  = 130;

    function initialize() {
        ORunBase.initialize();
    }

    function onUpdate(dc)
    {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        var width = dc.getWidth();
        var halfWitt = width / 2;
        var topcenter = halfWitt - 22;
        var botcenter = halfWitt - 15;
		var middlew = width / 3;
		var halfMiddleWitt = middlew / 2;
        
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
        dc.drawText( 0, 0, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_LEFT); 
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( topcenter - 10, 5, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT );
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( width - 2, 0, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_RIGHT );
        dc.drawText( topcenter + 10, 5, Gfx.FONT_NUMBER_MEDIUM, getSld(), Gfx.TEXT_JUSTIFY_LEFT );
        
        // -------------
        // MIDDLE fields
        // -------------
		var midfont = Gfx.FONT_LARGE;

        var hrString = (heart != null ? heart.toString() : "");
        dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) {
        	dc.drawText( middlew + halfMiddleWitt, firstYDat, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( middlew + halfMiddleWitt, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------
        
        dc.drawText( (halfWitt / 2) + 5, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (halfWitt / 2) + 5, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( (3 * halfWitt / 2) - 5, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (3 * halfWitt / 2) - 5, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------------
        // Bottom fields
        // -------------
        dc.drawText( botcenter + 40, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
        var batt = Sys.getSystemStats().battery.toNumber();
        ORunBase.setBatteryColor(dc, batt);
        dc.drawText( botcenter - 32, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);
    }
}

class ORunFr920xt extends ORunBase {

	const firstY     = 45;
	const firstYLbl  = 46;
	const firstYDat  = 61;
	const secondY    = 87;
	const secondYLbl = 113;
	const secondYDat = 90;
	const thirdY     = 130;
	const thirdYDat  = 132;

    function initialize() {
        ORunBase.initialize();
    }

    function onUpdate(dc)
    {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        var width = dc.getWidth();
        var halfWitt = width / 2;
        var topcenter = halfWitt - 22;
        var botcenter = halfWitt - 15;
		var middlew = width / 3;
		var halfMiddleWitt = middlew / 2;
        
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
        dc.drawText( 0, 0, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_LEFT); 
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( topcenter - 10, 5, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT );
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( width - 2, 0, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_RIGHT );
        dc.drawText( topcenter + 10, 5, Gfx.FONT_NUMBER_MEDIUM, getSld(), Gfx.TEXT_JUSTIFY_LEFT );
        
        // -------------
        // MIDDLE fields
        // -------------
		var midfont = Gfx.FONT_LARGE;

        var hrString = (heart != null ? heart.toString() : "");
        dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) {
        	dc.drawText( middlew + halfMiddleWitt, firstYDat, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( middlew + halfMiddleWitt, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( 2 * middlew + halfMiddleWitt, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------
        
        dc.drawText( (halfWitt / 2) + 5, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (halfWitt / 2) + 5, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( (3 * halfWitt / 2) - 5, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (3 * halfWitt / 2) - 5, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------------
        // Bottom fields
        // -------------
        dc.drawText( botcenter + 40, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
        var batt = Sys.getSystemStats().battery.toNumber();
        ORunBase.setBatteryColor(dc, batt);
        dc.drawText( botcenter - 32, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);
    }
}