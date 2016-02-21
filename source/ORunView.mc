using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

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
    	//backcol = Gfx.COLOR_BLACK;
    	//forecol = Gfx.COLOR_WHITE;
    	
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
        
        dc.drawLine( 0, 80, width, 80);
        dc.drawLine( topcenter, 80, topcenter, 0 );
        dc.drawLine( 0, 185, width, 185);
        
        dc.setPenWidth(1);
        dc.drawLine( 0, 132, width, 132 );
        dc.drawLine( middlew, 80, middlew, 132 );
        dc.drawLine( 2 * middlew, 80, 2 * middlew, 132 );
        
        dc.drawLine( halfWitt, 132, halfWitt, 185 );
        
        dc.drawLine( botcenter, 185, botcenter, dc.getHeight() );
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
        dc.drawText( halfMiddleWitt, 81, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, 96, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( middlew + halfMiddleWitt, 81, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) {
        	dc.drawText( middlew + halfMiddleWitt, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( middlew + halfMiddleWitt, 96, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        dc.drawText( 2 * middlew + halfMiddleWitt, 81, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( 2 * middlew + halfMiddleWitt, 96, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------
        
        dc.drawText( (halfWitt / 2) + 5, 131, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (halfWitt / 2) + 5, 164, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        dc.drawText( (3 * halfWitt / 2) - 5, 131, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( (3 * halfWitt / 2) - 5, 164, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // -------------
        // Bottom fields
        // -------------
        var batt = Sys.getSystemStats().battery.toNumber() + "%";
        dc.drawText( botcenter - 7, 189, Gfx.FONT_XTINY, batt, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText( botcenter + 7, 189, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
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
}