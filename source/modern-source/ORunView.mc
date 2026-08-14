using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

	// mike note: following are UI settings to work with various dimensions of Garmin device - possibly better to use barrels and put these variables in separate device-specific file
	// const devSemiRound  = 1;
	// const devVivoactive = 2;
	// const devFenix3     = 3;
	// const devEpix       = 4;
	// const devFenix5     = 5;
	// const devFenix6     = 6;
	// const devFenix7     = 7;
	// const devFr920      = 9;
    // var dev = devFenix3; // mike note: default Fenix3 dimensions for UI arrangement

	// more device-specific dimensions values for UI arrangement
	var Y_____1     		= 80;
	var Ylbl_PHT  	= 81;
	var Ydat_PHT  	= 96;
	var Y_____2    		= 132;
	var Ylbl_TS 	= 164;
	var Ydat_TS 	= 131;
	var Y_____3     		= 185;
	var Ydat_BT  	= 189;
	
    var rezWidth 		= 218; // defaults but safe defaults
    var halfWitt;
	var middlew;
	var halfMiddleWidth;
    var topCenter;
    var bottomCenter;
	
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
	var bottomAlign1;
	var bottomAlign2;

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
		//Sys.println("-----------------------------onLayout called - poss change in LAYOUTs-------- dcWidth: " + dc.getWidth() + "    dcHeight: " + dc.getHeight());
		// below here testing eventual responsive design for rectangle watches first
		var dcWidth = dc.getWidth(); // mike note: I changed this back to rezWidth, which
									 // means it's important to ensure that resources.xml 
									 // have the correct width in it at the top! 
		var dcHeight = dc.getHeight();

		rezWidth = Ui.loadResource(Rez.Strings.width).toNumber(); //easier to use dc.getWidth(), but easier to debug/maintain if we load from resource file
	    if (rezWidth != dc.getWidth()) {
			Sys.println("ERROR: dc.getWidth() does not match Ui.loadResource(Rez.Strings.width).toNumber()");
		}

		// old resources.xml direct metrics processing
		var Ylbl_GF = Ui.loadResource(Rez.Strings.Ylbl_GF).toNumber();
		var Ydat_GF = Ui.loadResource(Rez.Strings.Ydat_GF).toNumber();
		Y_____1 = Ui.loadResource(Rez.Strings.Y_____1).toNumber();
		Ylbl_PHT = Ui.loadResource(Rez.Strings.Ylbl_PHT).toNumber();
		Ydat_PHT = Ui.loadResource(Rez.Strings.Ydat_PHT).toNumber();
		Y_____2 = Ui.loadResource(Rez.Strings.Y_____2).toNumber();
		Ydat_TS = Ui.loadResource(Rez.Strings.Ydat_TS).toNumber();
		Ylbl_TS = Ui.loadResource(Rez.Strings.Ylbl_TS).toNumber();
		Y_____3 = Ui.loadResource(Rez.Strings.Y_____3).toNumber();
		Ydat_BT = Ui.loadResource(Rez.Strings.Ydat_BT).toNumber();
		var XtopCenter = Ui.loadResource(Rez.Strings.XtopCenter).toNumber();
		var XtopOffsets = Ui.loadResource(Rez.Strings.XtopOffsets).toNumber();
		var XbtmCenter = Ui.loadResource(Rez.Strings.XbtmCenter).toNumber();
		var XbtmOffsets = Ui.loadResource(Rez.Strings.XbtmOffsets).toNumber();

		// THIS WORKS!!!!
		// var testFloat = (dcHeight * Ui.loadResource(Rez.Strings.testfloat).toFloat()).toNumber(); 
		// System.println(" ***testing testFloat Y1: " + testFloat);

		// test new resources.xml metrics processing
		// var Ylbl_GF = (rezWidth * Ui.loadResource(Rez.Strings.Ylbl_GF).toFloat()).toNumber();
		// var Ydat_GF = (rezWidth * Ui.loadResource(Rez.Strings.Ydat_GF).toFloat()).toNumber();
		// Y_____1 = (dcHeight * Ui.loadResource(Rez.Strings.Y_____1).toFloat()).toNumber();
		// Ylbl_PHT = (dcHeight * Ui.loadResource(Rez.Strings.Ylbl_PHT).toFloat()).toNumber();
		// Ydat_PHT = (dcHeight * Ui.loadResource(Rez.Strings.Ydat_PHT).toFloat()).toNumber();
		// Y_____2 = (dcHeight * Ui.loadResource(Rez.Strings.Y_____2).toFloat()).toNumber();
		// Ydat_TS = (dcHeight * Ui.loadResource(Rez.Strings.Ydat_TS).toFloat()).toNumber();
		// Ylbl_TS = (dcHeight * Ui.loadResource(Rez.Strings.Ylbl_TS).toFloat()).toNumber();
		// Y_____3 = (dcHeight * Ui.loadResource(Rez.Strings.Y_____3).toFloat()).toNumber();
		// Ydat_BT = (dcHeight * Ui.loadResource(Rez.Strings.Ydat_BT).toFloat()).toNumber();
		// var XtopCenter = (rezWidth * Ui.loadResource(Rez.Strings.XtopCenter).toFloat()).toNumber();
		// var XtopOffsets = (rezWidth * Ui.loadResource(Rez.Strings.XtopOffsets).toFloat()).toNumber();
		// var XbtmCenter = (rezWidth * Ui.loadResource(Rez.Strings.XbtmCenter).toFloat()).toNumber();
		// var XbtmOffsets = (rezWidth * Ui.loadResource(Rez.Strings.XbtmOffsets).toFloat()).toNumber();



		halfWitt = rezWidth / 2;
		middlew = rezWidth / 3;
		halfMiddleWidth = middlew / 2;
		altX = middlew + halfMiddleWidth;
		tidX = (halfWitt / 2) + 5;
		distX = (3 * halfWitt / 2) - 5;
		paceX = 2 * middlew + halfMiddleWidth;
		
		topCenter = halfWitt + XtopCenter;    // X adjustment from middle of top vertical line
	    bottomCenter = halfWitt + XbtmCenter; // X adjustment from middle of bottom vertical line
		todX = bottomCenter + XbtmOffsets;        // X adjustment from bottom vertical for time-of-day
		battX = bottomCenter - XbtmOffsets;      // X adjustment from bottom vertical for battery pct
		
		var shape = System.getDeviceSettings().screenShape;
		var rezShape = Ui.loadResource(Rez.Strings.shape);
		//System.println("rezShape detected as " + rezShape + " with dimensions rez-> W_" + rezWidth + " x H_" + dcHeight + " <-dc");
		if ((shape == System.SCREEN_SHAPE_RECTANGLE) && (!rezShape.equals("rectangle"))) {
			Sys.println("ERROR: System.getDeviceSettings().screenShape does not match Ui.loadResource(Rez.Strings.shape)");
		}
		
		// default for round layout  (rezShape == System.SCREEN_SHAPE_ROUND)
		slbX1 = topCenter - XtopOffsets;
		slbY1 = Ylbl_GF;
		slbX2 = topCenter - XtopOffsets;
		slbY2 = Ydat_GF;
		sldX1 = topCenter + XtopOffsets;
		sldY1 = Ylbl_GF;
		sldX2 = topCenter + XtopOffsets;
		sldY2 = Ydat_GF;
		// default align for round layout  (rezShape == System.SCREEN_SHAPE_ROUND)
		topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
		topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
		topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
		topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
		bottomAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
		bottomAlign2 = Gfx.TEXT_JUSTIFY_LEFT;

		// alter if rectangle layout...
		if (shape == System.SCREEN_SHAPE_RECTANGLE) {
			slbX1 = XtopOffsets;
			//slbY1 = 0;
			//slbX2 = topCenter - 10;
			//slbY2 = 5;
			sldX1 = rezWidth - 2 - XtopOffsets;
			//sldY1 = 0;
			//sldX2 = topCenter + 10;
			//sldY2 = 5;
			topAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			battX = XbtmOffsets;
			todX = rezWidth - XbtmOffsets;
		} else if (System has :SCREEN_SHAPE_SEMI_OCTAGON){ // first confirm that watch recognizes the terminology octagonal
			if (shape == System.SCREEN_SHAPE_SEMI_OCTAGON) {
				if (!rezShape.equals("semioctagon")) {
					Sys.println("ERROR: System.getDeviceSettings().screenShape does not match Ui.loadResource(Rez.Strings.shape)");
				}
				// get dimensions, center of small circular screen at top right
			    var subscreenInfo = WatchUi.getSubscreen();
				var x, y, width, height, centerX, centerY;

				if (subscreenInfo != null) {
					x = subscreenInfo.x;
					y = subscreenInfo.y;
					width = subscreenInfo.width;
					height = subscreenInfo.height;
					// Calculate center coordinates for printing text
					centerX = x + (width / 2);
					centerY = y + (height / 2);
				}
				


				// slb/bearing from lap/start		 
				slbX1 = topCenter + XtopOffsets; // Switch add/subtract so bearing appears in the smaller circle, raise
				slbY1 = Ylbl_GF;
				slbX2 = topCenter + XtopOffsets;
				slbY2 = Ydat_GF; // - 20; // so bearing appears raised... 20 pixels higher than dist on left side..

				// sld/distance from lap/start
				sldX1 = topCenter - XtopOffsets;
				sldY1 = Ylbl_GF;
				sldX2 = topCenter - XtopOffsets;
				sldY2 = Ydat_GF;
			} 
		// } else { // useful if we had a standalone if statement for semioctagonal screen...
		// 	Sys.println("ERROR: Loaded semioctagonal source but device does not recognize System.SCREEN_SHAPE_SEMI_OCTAGON");
		}
		
		// using the below function we can see patterns to ui, develop a simpler algorithm 
		// for adjusting UI metrics, rather than assigning each location uniquely per device.
		var device = Ui.loadResource(Rez.Strings.deviceTypeHelper);
		System.println("============================================================ " + getModelIdentifier());
		System.println("Device: " + device + "   (part number " + getModelIdentifier() + ")     (dcHeight:" + dc.getHeight() + " dcWidth:" + dc.getWidth() + ")");
		System.println("---------------------legible metrics------------------------");
		System.println(" XtopCenter: " + (XtopCenter.toFloat()/rezWidth).format("%.3f") + " (" + XtopCenter + ")");
		System.println("XtopOffsets: " + (XtopOffsets.toFloat()/rezWidth).format("%.3f") + " (" + XtopOffsets + ")");
		System.println("");
		System.println("    Ylbl_GF: " + (Ylbl_GF.toFloat()/dcHeight).format("%.3f") + " (" + Ylbl_GF + ")");
		System.println("    Ydat_GF: " + (Ydat_GF.toFloat()/dcHeight).format("%.3f") + " (" + Ydat_GF + ")");
		System.println("");
		System.println("    Y_____1: " + (Y_____1.toFloat()/dcHeight).format("%.3f") + " (" + Y_____1 + ")");
		System.println("   Ylbl_PHT: " + (Ylbl_PHT.toFloat()/dcHeight).format("%.3f") + " (" + Ylbl_PHT + ")");
		System.println("   Ydat_PHT: " + (Ydat_PHT.toFloat()/dcHeight).format("%.3f") + " (" + Ydat_PHT + ")");
		System.println("");
		System.println("    Y_____2: " + (Y_____2.toFloat()/dcHeight).format("%.3f") + " (" + Y_____2 + ")");
		System.println("    Ydat_TS: " + (Ydat_TS.toFloat()/dcHeight).format("%.3f") + " (" + Ydat_TS + ")");
		System.println("    Ylbl_TS: " + (Ylbl_TS.toFloat()/dcHeight).format("%.3f") + " (" + Ylbl_TS + ")");
		System.println("");
		System.println("    Y_____3: " + (Y_____3.toFloat()/dcHeight).format("%.3f") + " (" + Y_____3 + ")");
		System.println("    Ydat_BT: " + (Ydat_BT.toFloat()/dcHeight).format("%.3f") + " (" + Ydat_BT + ")");
		System.println("");
		System.println(" XbtmCenter: " + (XbtmCenter.toFloat()/rezWidth).format("%.3f") + " (" + XbtmCenter + ")");
		System.println("XbtmOffsets: " + (XbtmOffsets.toFloat()/rezWidth).format("%.3f") + " (" + XbtmOffsets + ")");
		System.println("---------------------- X M L metrics ----------------------");
		System.println("<resources>");
		System.println("    <!-- dimensions & type of device + reference device --> ");
		System.println("    <string id=\"deviceTypeHelper\">" + device + "</string>");
		System.println("    <!-- values are checked with system during run -->");
		System.println("    <string id=\"shape\">" + rezShape + "</string>");
		System.println("    <string id=\"width\">" + rezWidth + "</string>");
		System.println("");
		System.println("    <string id=\"XtopCenter\">" + (XtopCenter.toFloat()/rezWidth).format("%.3f") + "</string>  <!--    Center Line Top  -->");
		System.println("    <string id=\"XtopOffsets\">" + (XtopOffsets.toFloat()/rezWidth).format("%.3f") + "</string> <!-- Margin to Line Top  -->");
		System.println("");
		System.println("    <string id=\"Ylbl_GF\">" + (Y_____1.toFloat()/dcHeight).format("%.3f") + "</string>     <!--  Labels Deg & SLD   -->");
		System.println("    <string id=\"Ydat_GF\">" + (Ydat_GF.toFloat()/dcHeight).format("%.3f") + "</string>     <!--    Data Deg & SLD   -->");
		System.println("");
		System.println("    <string id=\"Y_____1\">" + (Y_____1.toFloat()/dcHeight).format("%.3f") + "</string>     <!--      Top Line       -->");
		System.println("    <string id=\"Ylbl_PHT\">" + (Ylbl_PHT.toFloat()/dcHeight).format("%.3f") + "</string>    <!-- Labels HR Alt Pace  -->");
		System.println("    <string id=\"Ydat_PHT\">" + (Ydat_PHT.toFloat()/dcHeight).format("%.3f") + "</string>    <!--   Data HR Alt Pace  -->");
		System.println("");
		System.println("    <string id=\"Y_____2\">" + (Y_____2.toFloat()/dcHeight).format("%.3f") + "</string>     <!--   Mid Line (thin)   -->");
		System.println("    <string id=\"Ydat_TS\">" + (Ydat_TS.toFloat()/dcHeight).format("%.3f") + "</string>     <!--   Data Timer & Dist -->");
		System.println("    <string id=\"Ylbl_TS\">" + (Ylbl_TS.toFloat()/dcHeight).format("%.3f") + "</string>     <!-- Labels Timer & Dist -->");
		System.println("");
		System.println("    <string id=\"Y_____3\">" + (Y_____3.toFloat()/dcHeight).format("%.3f") + "</string>     <!--     Bottom Line     -->");
		System.println("    <string id=\"Ydat_BT\">" + (Ydat_BT.toFloat()/dcHeight).format("%.3f") + "</string>     <!--   Data Batt & Tod   -->");
		System.println("");
		System.println("    <string id=\"XbtmCenter\">" + (XbtmCenter.toFloat()/rezWidth).format("%.3f") + "</string> <!--    Center Line Btm  -->");
		System.println("    <string id=\"XbtmOffsets\">" + (XbtmOffsets.toFloat()/rezWidth).format("%.3f") + "</string> <!-- Margin to Line Btm  -->");
		System.println("");
		System.println("</resources>\n\n");
		System.print("============================================================ ");
		System.println(getModelIdentifier() + "  device tested: XXXXXX");
				
		
    }
	// -------------------------------------------------------------------------------------------------------------------
	function getModelIdentifier() {
		var settings = System.getDeviceSettings();
		if (settings has :partNumber && settings.partNumber != null) {
			return settings.partNumber;
		}
		return "Unknown";
	}	
	// -------------------------------------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------------------------------------
	// after this is business logic, less focused on device-specific display metrics
	// -------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------
	function initialize() {  // mike note: initialize loads strings, get unit-settings
        DataField.initialize();
		core = new ORunCore();
    
		// mike note: useful for debugging display
		backcol = Gfx.COLOR_WHITE;
		forecol = Gfx.COLOR_BLACK;
    	
		//backcol = Gfx.COLOR_BLACK;	// dark mode (normal for production) // mike note: initialize color settings
		//forecol = Gfx.COLOR_WHITE;
    	

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
		
		// Modern layout metrics are loaded in onLayout from device profile resources.
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
        dc.drawLine( 0, Y_____1, rezWidth, Y_____1);         // Top horizontal 
        dc.drawLine( topCenter, Y_____1, topCenter, 0 ); // Top vertical split-line
        dc.drawLine( 0, Y_____3, rezWidth, Y_____3);         // Bottom horizontal 
        
        // Draw the thin middle lines 
        dc.setPenWidth(1);
        dc.drawLine( 0, Y_____2, rezWidth, Y_____2 );                    // Middle horizontal 
        dc.drawLine( middlew, Y_____1, middlew, Y_____2 );             // HR/Alt vertical split-line 
        dc.drawLine( 2 * middlew, Y_____1, 2 * middlew, Y_____2 );     // Alt/Pace vertical split-line
        
        dc.drawLine( halfWitt, Y_____2, halfWitt, Y_____3 );           // Timer/Dist vertical split-line
        
        dc.drawLine( bottomCenter, Y_____3, bottomCenter, dc.getHeight() );  // Battery/Time vertical split-line
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
        dc.drawText( halfMiddleWidth, Ylbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( halfMiddleWidth, Ydat_PHT, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: middle center - altitude with unit conversion
        dc.drawText( altX, Ylbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) { // mike note: if elevation over 9999 (10k ft or m?), use smaller font (med instead of large)
        	dc.drawText( altX, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dc.drawText( altX, Ydat_PHT, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
		// mike note: middle right - pace with unit conversion
        dc.drawText( paceX, Ylbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( paceX, Ydat_PHT, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER ); 					
        
        // ------- // mike note: lower half of middle fields 
        
		// mike note: lower middle left - elapsed activity time, formatted
        dc.drawText( tidX, Ydat_TS, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( tidX, Ylbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: lower middle right - converted activity distance total (does not reset upon new lap)
        dc.drawText( distX, Ydat_TS, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dc.drawText( distX, Ylbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // ------------- ////////////////////////////////////
        // Bottom fields ////////////////////////////////////
        // ------------- ////////////////////////////////////
        
		// mike note: time of day HH:MM:SS
		dc.drawText( todX, Ydat_BT, Gfx.FONT_XTINY, getTod(), bottomAlign2); //Gfx.TEXT_JUSTIFY_LEFT );
        
		// mike note: battery percentage, writing in different color depending upon percentage
        var batt = Sys.getSystemStats().battery.toNumber();
        setBatteryColor(dc, batt);
        dc.drawText( battX, Ydat_BT, Gfx.FONT_XTINY, batt + "%", bottomAlign1); // Gfx.TEXT_JUSTIFY_RIGHT);

		// mike note: for testing memory
		// System.println(memstr());    
	}
	// mike note: for testing memory
	//function memstr () { return ((Toybox.System.getSystemStats().freeMemory.toFloat()/Toybox.System.getSystemStats().totalMemory.toFloat()) * 100).toNumber() + "% available"; } 
}
// ======================================================================================================================
// notes below, class ends here