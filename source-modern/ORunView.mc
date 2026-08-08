using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

	// mike note: following are UI settings to work with various dimensions of Garmin device - possibly better to use barrels and put these variables in separate device-specific file
	const devSemiRound  = 1;
	const devVivoactive = 2;
	const devFenix3     = 3;
	const devEpix       = 4;
	const devFenix5     = 5;
	const devFenix6     = 6;
	const devFenix7     = 7;
	const devFr920      = 9;

    var dev = devFenix3; // mike note: default Fenix3 dimensions for UI arrangement

	// more device-specific dimensions values for UI arrangement
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

	var altX;
	var tidX;
	var distX;
	var paceX;
	var todX;
	var battX;





	// mike note: ----------------------------- after this line variables are used for core functionality, NOT DEVICE SPECIFIC

	// mike note: other view variables - colors
	var backcol;
	var forecol;
	var linecol;

	// mike note: 
	var distLabel;
	var paceLabel;
	var slbLabel;
	var sldLabel;
	var tmrLabel;
	var hbtLabel;
	var altLabel;

	// mike note: conversion factor values for far-distance 'dist' for miles/km and short-distance 'unit' for feet/meters
	var distConv;
	var unitConv;
	var core;

	
	// -------------------------------------------------------------------------------------------------------------------
    function onLayout(dc) {
		var profile = Ui.loadResource(Rez.Strings.layoutProfile);
		if (profile.equals("modern")) {
			initModernLayout(dc);
		}
    }
	// -------------------------------------------------------------------------------------------------------------------
	function initModernLayout(dc) {
		var h = dc.getHeight();
		var w = dc.getWidth();

		dev = devFenix6;
		firstY = (h * 40 / 100).toNumber();
		firstYLbl = firstY + 5;
		firstYDat = firstY + 24;
		secondY = (h * 65 / 100).toNumber();
		secondYLbl = secondY + 36;
		secondYDat = secondY + 2;
		thirdY = (h * 88 / 100).toNumber();
		thirdYDat = thirdY + 2;

		calcXVals(w, -15, -15, 7, -7);
		applyModernSpacing(dc);
	}
	// -------------------------------------------------------------------------------------------------------------------
	function applyModernSpacing(dc) {
		var smallH = dc.getFontHeight(Gfx.FONT_XTINY);
		var halfH = (smallH / 2).toNumber();
		var topX = Ui.loadResource(Rez.Strings.topShiftX).toNumber();
		var topLabelY = Ui.loadResource(Rez.Strings.topLabelShiftY).toNumber();
		var topValueY = Ui.loadResource(Rez.Strings.topValueShiftY).toNumber();
		var middleTopLabelY = Ui.loadResource(Rez.Strings.middleTopLabelShiftY).toNumber();
		var middleTopValueY = Ui.loadResource(Rez.Strings.middleTopValueShiftY).toNumber();
		var middleBottomLabelY = Ui.loadResource(Rez.Strings.middleBottomLabelShiftY).toNumber();
		var middleBottomValueY = Ui.loadResource(Rez.Strings.middleBottomValueShiftY).toNumber();

		topcenter += topX;
		slbX1 += topX;
		slbX2 += topX;
		sldX1 += topX;
		sldX2 += topX;

		slbY1 += smallH + topLabelY;
		slbY2 += smallH + topValueY;
		sldY1 += smallH + topLabelY;
		sldY2 += smallH + topValueY;

		firstYLbl += halfH + middleTopLabelY;
		firstYDat += halfH + middleTopValueY;

		secondYLbl += smallH + middleBottomLabelY;
		secondYDat += smallH + middleBottomValueY;
	}
	// -------------------------------------------------------------------------------------------------------------------
    
	function initialize() {  // mike note: initialize loads strings, get unit-settings
        DataField.initialize();
		core = new ORunCore();
    
    	backcol = Gfx.COLOR_WHITE;										// mike note: unnecessary initialization of color settings
    	forecol = Gfx.COLOR_BLACK;										// mike note: these two statements could probably be removed
    	
    	// Inverted
    	backcol = Gfx.COLOR_BLACK;										// mike note: initialize color settings
    	forecol = Gfx.COLOR_WHITE;
    	
    	linecol = Gfx.COLOR_BLUE;
    	
    	slbLabel = Ui.loadResource(Rez.Strings.slb);					// mike note: load strings for datafield labels
    	tmrLabel = Ui.loadResource(Rez.Strings.timer);
		paceLabel = Ui.loadResource(Rez.Strings.pace);
		distLabel = Ui.loadResource(Rez.Strings.dist);
		hbtLabel = Ui.loadResource(Rez.Strings.hbt);
		altLabel = Ui.loadResource(Rez.Strings.alt);
		
    	if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) { // mike note: update conversion factor to miles/feet
    		sldLabel = Ui.loadResource(Rez.Strings.sld_ft);
    		unitConv = 1609;
    		distConv = 3.28084;
			core.setDistanceConversion(distConv);
			core.setUnitConversion(unitConv);
    	}
    	else { 													 // mike note: update conversion factor to kilometers/meters
    		sldLabel = Ui.loadResource(Rez.Strings.sld_m);
    		unitConv = 1000;
    		distConv = 1;
			core.setDistanceConversion(distConv);
			core.setUnitConversion(unitConv);
    	}
    	
    	initDevice();
    }
    // -------------------------------------------------------------------------------------------------------------------




























    function initDevice() {
		System.println("running initialization for sizing");

    	var dv = Ui.loadResource(Rez.Strings.device);
        if (dv.equals("fenix7x")) {
					   dev = devFenix7;
					   setDeviceLayout(100, 101, 120, 170, 220, 180, 242, 250);
			calcXVals(280, -15, -15, 7, -7);
            return;
        }
        else if (dv.equals("fenix7") ||
                 dv.equals("fenix6") ||
                 dv.equals("fenix6pro")) {
					   dev = devFenix6;
					   setDeviceLayout(105, 110, 124, 170, 206, 172, 228, 230);
			calcXVals(260, -15, -15, 7, -7);
            return;
        }
        else if (dv.equals("fenix6xpro")) {
					   dev = devFenix6;
					   setDeviceLayout(110, 115, 130, 180, 220, 182, 246, 248);
			calcXVals(280, -10, -15, 7, -7);
            return;
        }
        else if (dv.equals("fenix5") ||
                 dv.equals("fenix5x")) {
					   dev = devFenix5;
					   setDeviceLayout(80, 81, 104, 140, 172, 142, 200, 202);
			calcXVals(240, -15, -20, 5, -5);
            return;
        }
        else if (dv.equals("vivoactive")) {
				   dev = devVivoactive;
				   setDeviceLayout(45, 46, 61, 91, 113, 90, 131, 132);
		     calcXVals(205, -22, -15, 40, -32);
            return;
    	}
    	else if (dv.equals("fr920xt")) {
				   dev = devFr920;
				   setDeviceLayout(45, 46, 61, 87, 113, 90, 130, 132);
		     calcXVals(205, -22, -15, 40, -32);
            return;
    	}
    	else if (dv.equals("epix")) {
				   dev = devEpix;
				   setDeviceLayout(42, 43, 57, 87, 110, 86, 130, 130);
		     calcXVals(205, -22, -15, 40, -32);
            return;
    	}
    	else if (dv.equals("fr230") ||
    	         dv.equals("fr235") ||
    	         dv.equals("fr630") ||
    	         dv.equals("fr735xt")) {
				   dev = devSemiRound;
				   setDeviceLayout(60, 61, 77, 110, 139, 110, 160, 160);
		     calcXVals(218, -15, -15, 7, -7);
            return;
    	}
    	
        // Default settings are for fenix 3
		dev = devFenix3;
		setDeviceLayout(80, 81, 96, 132, 164, 131, 185, 189);
	 calcXVals(218, -15, -15, 7, -7);
    }
    // -------------------------------------------------------------------------------------------------------------------
	function setDeviceLayout(y1, yl1, yd1, y2, yl2, yd2, y3, yd3) {
		firstY = y1;
		firstYLbl = yl1;
		firstYDat = yd1;
		secondY = y2;
		secondYLbl = yl2;
		secondYDat = yd2;
		thirdY = y3;
		thirdYDat = yd3;
	}
	// -------------------------------------------------------------------------------------------------------------------

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
			setRoundTop(7, 10, 30);
		}
		else if (dev == devFenix6) {
		    // Round watches ...
			setRoundTop(7, 10, 37);
		}
		else if (dev == devFenix5) {
		    // Round watches ...
			setRoundTop(10, 10, 37);
		}
		else if (dev == devFenix3) {
		    // Round watches ...
			setRoundTop(10, 10, 20);
		}
		else if (dev == devSemiRound) {
		    // Semi-Round watches ...
			setRoundTop(10, 0, 13);
		}
		else {
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
    }
	// -------------------------------------------------------------------------------------------------------------------
	function setRoundTop(offset, y1, y2) {
		slbX1 = topcenter - offset;
		slbY1 = y1;
		slbX2 = topcenter - offset;
		slbY2 = y2;
		sldX1 = topcenter + offset;
		sldY1 = y1;
		sldX2 = topcenter + offset;
		sldY2 = y2;
	}
	// -------------------------------------------------------------------------------------------------------------------
    
	



























	//! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
		core.compute(info);
    }
    // -------------------------------------------------------------------------------------------------------------------
    function onTimerStart() { // mike note: increment lap when user presses start, which is interesting to me
		core.onTimerStart();
        Ui.requestUpdate();
    }
    // -------------------------------------------------------------------------------------------------------------------
    function onTimerLap() { // mike note: increment lap when user presses lap
		core.onTimerLap();
        Ui.requestUpdate();
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getPace() {
	return core.getPace(core.speed);
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getDist() {
	return core.getDist(core.dist);
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getAlt() {
	return core.getAlt(core.alt);
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getTid() {
	return core.getTid(core.tid);
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getTod() {
    	return core.getTod();
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getBearing() { // mike note: safety wrapper for computeBearing // this could be best, although other ways exist to do this
	    if (core.startLoca != null and core.loca != null) {
			return core.computeBearing(core.startLoca, core.loca).toString();
    	}
    	return ""; //  mike note: returns string
    }
    // -------------------------------------------------------------------------------------------------------------------
    function getSld() { // mike note: safety wrapper for computeBearing // this could be best, although other ways exist to do this
	    if (core.startLoca != null and core.loca != null) {
			return core.computeDistance(core.startLoca, core.loca).toString();
    	} 
    	return ""; //  mike note: returns string
    }
	// -------------------------------------------------------------------------------------------------------------------
	function setBatteryColor(dc, battery) { // mike note: change color of battery % if over 30%, over 10%
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
	// -------------------------------------------------------------------------------------------------------------------
    //! Handle the update event
    function onUpdate(dc) 
    {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear(); // paint background color
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3); // set foreground color linecol for printing lines, text
        
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
		
        // ---------- ////////////////////////////////////
        // TOP fields ////////////////////////////////////
        // ---------- ////////////////////////////////////
        
		// mike note: top left - Deg / slb - degrees bearing (in RED medium font)
        dc.drawText( slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, topAlign1 );
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dc.drawText( slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), topAlign2 );
        
		// mike note: top right - SLD straight-line distance in ft or m (in med font)
		dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dc.drawText( sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, topAlign3 );
        dc.drawText( sldX2, sldY2, Gfx.FONT_NUMBER_MEDIUM, getSld(), topAlign4 );
        
        // ------------- ////////////////////////////////////
        // MIDDLE fields ////////////////////////////////////
        // ------------- ////////////////////////////////////
		var midfont = Gfx.FONT_LARGE;

		// mike note: middle left - heart rate in bpm
		var hrString = (core.heart != null ? core.heart.toString() : "");
        dc.drawText( halfMiddleWitt, firstYLbl, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWitt, firstYDat, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: middle center - altitude with unit conversion
        dc.drawText( altX, firstYLbl, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) { // mike note: if elevation over 9999 (10k ft or m?), use smaller font (med instead of large)
        	dc.drawText( altX, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( altX, firstYDat, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
		// mike note: middle right - pace with unit conversion
        dc.drawText( paceX, firstYLbl, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( paceX, firstYDat, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER ); 					
        
        // ------- // mike note: lower half of middle fields 
        
		// mike note: lower middle left - elapsed activity time, formatted
        dc.drawText( tidX, secondYDat, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( tidX, secondYLbl, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: lower middle right - converted activity distance total (does not reset upon new lap)
        dc.drawText( distX, secondYDat, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( distX, secondYLbl, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // ------------- ////////////////////////////////////
        // Bottom fields ////////////////////////////////////
        // ------------- ////////////////////////////////////
        
		// mike note: time of day HH:MM:SS
		dc.drawText( todX, thirdYDat, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT );
        
		// mike note: battery percentage, writing in different color depending upon percentage
        var batt = Sys.getSystemStats().battery.toNumber();
        setBatteryColor(dc, batt);
        dc.drawText( battX, thirdYDat, Gfx.FONT_XTINY, batt + "%", Gfx.TEXT_JUSTIFY_RIGHT);

		System.println(memstr());    
	}
	function memstr () { return ((Toybox.System.getSystemStats().freeMemory.toFloat()/Toybox.System.getSystemStats().totalMemory.toFloat()) * 100).toNumber() + "% available"; } 

}