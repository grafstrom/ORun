using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {

	var oY_____1;
	var oYlbl_PHT;
	var oYdat_PHT;
	var oY_____2;
	var oYdat_TS;
	var oYlbl_TS;
	var oY_____3;
	var oYdat_BT;
	var xt0Mid;
	var lg4Mid;
	var md6Mid;
	var rezWidth;
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

	const DEBUG_PRINT_RATIOS = false;
	const DEBUG_PRINT_MIDLINES = false;

	// mike note: ----------------------------- after this line variables are used for core functionality, NOT DEVICE SPECIFIC

	// mike note: other view variables - colors
	var backcol;
	var forecol;
	var linecol;

	// mike note: label text for drawtexts..
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
		var XtopCenter;
		var XtopOffsets;
		var XbtmCenter;
		var XbtmOffsets;
		var oXtopCenter;
		var oXtopOffsets;
		var oYlbl_GF;
		var oYdat_GF;
		var oXbtmCenter;
		var oXbtmOffsets;

		//Sys.println("-----------------------------onLayout called - poss change in LAYOUTs-------- dcWidth: " + dc.getWidth() + "    dcHeight: " + dc.getHeight());
		// testing eventual responsive design for rectangle watches

		var shape = System.getDeviceSettings().screenShape;
		var rezShape = Ui.loadResource(Rez.Strings.shape);
		//System.println("rezShape detected as " + rezShape + " with dimensions rez-> W_" + rezWidth + " x H_" + dcHeight + " <-dc");
		if ((shape == System.SCREEN_SHAPE_RECTANGLE) && (!rezShape.equals("rectangle"))) {
			Sys.println("ERROR: System.getDeviceSettings().screenShape does not match Ui.loadResource(Rez.Strings.shape)");
		}


		var dcHeight = dc.getHeight();

		// handle width
		//var dcWidth = dc.getWidth(); // mike note: I changed this back to rezWidth, which
									 // means it's important to ensure that resources.xml 
									 // have the correct width in it at the top! 
		rezWidth = Ui.loadResource(Rez.Strings.width).toNumber(); //easier to use dc.getWidth(), but easier to debug/maintain if we load from resource file
	    if (rezWidth != dc.getWidth()) {
			Sys.println("ERROR: dc.getWidth() does not match Ui.loadResource(Rez.Strings.width).toNumber()");
		}


		// accurateHeight computed live (ascent+descent heuristic), no per-profile resource needed
		var xt0Acc = Gfx.getFontAscent(Gfx.FONT_XTINY).toFloat();
		if (Gfx.getFontDescent(Gfx.FONT_XTINY) != 0) {
			xt0Acc = (Gfx.getFontAscent(Gfx.FONT_XTINY).toFloat() + Gfx.getFontDescent(Gfx.FONT_XTINY).toFloat()) * 0.78;
		}
		var lg4Acc = Gfx.getFontAscent(Gfx.FONT_LARGE).toFloat();
		if (Gfx.getFontDescent(Gfx.FONT_LARGE) != 0) {
			lg4Acc = (Gfx.getFontAscent(Gfx.FONT_LARGE).toFloat() + Gfx.getFontDescent(Gfx.FONT_LARGE).toFloat()) * 0.78;
		}
		var md6Acc = Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM);
		if (Gfx.getFontDescent(Gfx.FONT_NUMBER_MEDIUM) != 0) {
			md6Acc = (Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM).toFloat() + Gfx.getFontDescent(Gfx.FONT_NUMBER_MEDIUM).toFloat()) * 0.78;
		}
		
		// 3. Find where the visual top of the numbers actually starts inside the raw block
		//var TopPadding = (getFontHeight - accurateHeight) / 2;
		var xt0TopPadding = (dc.getFontHeight(Gfx.FONT_XTINY).toFloat() - xt0Acc) / 2.0; // 
		var lg4TopPadding = (dc.getFontHeight(Gfx.FONT_LARGE).toFloat() - lg4Acc) / 2.0; // 
		var md6TopPadding = (dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM).toFloat() - md6Acc) / 2.0; // 
		//System.println("   TopPaddings are xt0TopPadding_" + xt0TopPadding.format("%.1f") + ", lg4TopPadding_" + lg4TopPadding.format("%.1f") + ", md6TopPadding_" + md6TopPadding.format("%.1f"));

		xt0Mid = xt0TopPadding + xt0Acc/2; // 
		lg4Mid = lg4TopPadding + lg4Acc/2; // 
		md6Mid = md6TopPadding + md6Acc/2; // 
		//System.println("   Mids are xt0Mid_" + xt0Mid.format("%.1f") + ", lg4Mid_" + lg4Mid.format("%.1f") + ", md6Mid_" + md6Mid.format("%.1f") + " // add to get center line for each: ");
		if (shape == System.SCREEN_SHAPE_RECTANGLE) {
			// if (dc.Height() >= )
			
			dcHeight = dc.getHeight();
			
		}

		oXtopCenter = Ui.loadResource(Rez.Strings.oXtopCenter).toFloat();
		oXtopOffsets = Ui.loadResource(Rez.Strings.oXtopOffsets).toFloat();
		oXbtmCenter = Ui.loadResource(Rez.Strings.oXbtmCenter).toFloat();
		oXbtmOffsets = Ui.loadResource(Rez.Strings.oXbtmOffsets).toFloat();
		oYlbl_GF = (dcHeight * Ui.loadResource(Rez.Strings.oYlbl_GF).toFloat());
		oYdat_GF = (dcHeight * Ui.loadResource(Rez.Strings.oYdat_GF).toFloat());
		oY_____1 = (dcHeight * Ui.loadResource(Rez.Strings.oY_____1).toFloat());
		oYlbl_PHT = (dcHeight * Ui.loadResource(Rez.Strings.oYlbl_PHT).toFloat());
		oYdat_PHT = (dcHeight * Ui.loadResource(Rez.Strings.oYdat_PHT).toFloat());
		oY_____2 = (dcHeight * Ui.loadResource(Rez.Strings.oY_____2).toFloat());
		oYdat_TS = (dcHeight * Ui.loadResource(Rez.Strings.oYdat_TS).toFloat());
		oYlbl_TS = (dcHeight * Ui.loadResource(Rez.Strings.oYlbl_TS).toFloat());
		oY_____3 = (dcHeight * Ui.loadResource(Rez.Strings.oY_____3).toFloat());
		oYdat_BT = (dcHeight * Ui.loadResource(Rez.Strings.oYdat_BT).toFloat());


		XtopCenter = oXtopCenter * rezWidth; //these are the pixel values, calculated from ratios in resources - kept Float to avoid precision decay on re-export
		XtopOffsets = oXtopOffsets * rezWidth;
		XbtmCenter = oXbtmCenter * rezWidth;
		XbtmOffsets = oXbtmOffsets * rezWidth;


		halfWitt = rezWidth / 2;
		middlew = rezWidth / 3;
		halfMiddleWidth = middlew / 2;
		altX = middlew + halfMiddleWidth;
		tidX = (halfWitt / 2) + 5;
		distX = (3 * halfWitt / 2) - 5;
		paceX = 2 * middlew + halfMiddleWidth;
		
		topCenter = halfWitt + XtopCenter;    // X adjustment from middle of top vertical line
		bottomCenter = halfWitt + XbtmCenter; // X adjustment from middle of bottom vertical line

		slbX2 = topCenter - XtopOffsets; // dat is still center-justified for all devices
		sldX2 = topCenter + XtopOffsets; // dat is still center-justified for all devices

		slbY1 = oYlbl_GF;
		slbY2 = oYdat_GF;
		sldY1 = oYlbl_GF;
		sldY2 = oYdat_GF;

		// handle top label (slb, sld), and bottom data (batt, tod) margin and justification
		if (shape == System.SCREEN_SHAPE_RECTANGLE) {
			// on rectangle devices, tld and tlb (at top), and batt & tod (at bottom) are SIDE-EDGE-justified
			slbX1 = XbtmOffsets; 					// use SAME as BOTTOM offset distance for slb label
			sldX1 = rezWidth - 2 - XbtmOffsets;   // use SAME as BOTTOM offset distance for slD label
			battX = XbtmOffsets;
			todX  = rezWidth - 2 - XbtmOffsets;
			// on rectangle devices, tld and tlb (at top), and batt & tod (at bottom) are SIDE-EDGE-justified
			topAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign1 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
		} else {
			//System.println(" not rectangular... ");
			// on round devices, tld and tlb (at top), and batt & tod (at bottom) are CENTER-justified
			slbX1 = topCenter - XtopOffsets;
			sldX1 = topCenter + XtopOffsets;
			battX = bottomCenter - XbtmOffsets;
			todX  = bottomCenter + XbtmOffsets;
			// on round devices, tld and tlb (at top), and batt & tod (at bottom) are CENTER-justified
			topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
			bottomAlign2 = Gfx.TEXT_JUSTIFY_LEFT;
		}
		
		// debug printlns for producing ratio output for resources.xml files
		if (DEBUG_PRINT_RATIOS) {
			System.println("");
			var device = Ui.loadResource(Rez.Strings.device);
			System.println("<!-- ============================================================ " + getModelIdentifier() + " -->");
			System.println("<!-- Device:" + device + "   (part number " + getModelIdentifier() + ")     (dcHeight:" + dc.getHeight() + " dcWidth:" + dc.getWidth() + ")   -->");
			System.println("<!-- Tested On: ");
			System.println("");
			System.println("-->");
			System.println("<resources>");
			System.println("    <string id=\"RunFromRatios\">true</string> <!-- always output true for formatting upgrade -->");
			System.println("    <string id=\"device\">" + device + "</string>");
			System.println("    <string id=\"shape\">" + rezShape + "</string>");
			System.println("    <string id=\"width\">" + rezWidth + "</string>");
			System.println("");
			System.println("    <!-- on this device, getFontHeight(Gfx.FONT_XTINY)         = " + dc.getFontHeight(Gfx.FONT_XTINY)         + " but actually pixelsTall_" + xt0Acc.format("%.06f") + ".  * 0.5 + padding_" + xt0TopPadding + " = " + xt0Mid.format("%.06f") + "_midpoint -->");
			System.println("    <!-- on this device, getFontHeight(Gfx.FONT_LARGE)         = " + dc.getFontHeight(Gfx.FONT_LARGE)         + " but actually pixelsTall_" + lg4Acc.format("%.06f") + ".  * 0.5 + padding_" + lg4TopPadding + " = " + lg4Mid.format("%.06f") + "_midpoint -->");
			System.println("    <!-- on this device, getFontHeight(Gfx.FONT_NUMBER_MEDIUM) = " + dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) + " but actually pixelsTall_" + md6Acc.format("%.06f") + ".  * 0.5 + padding_" + md6TopPadding + " = " + md6Mid.format("%.06f") + "_midpoint -->");
			System.println("");
			System.println("    <!--  KEEP HIGH PRECISION:  1 pixel / " + rezWidth + " (screen width) = " + (1.0/rezWidth).format("%.06f")+ " portion of screen  -->");
			System.println("");
			System.println("    <string id=\"oXtopCenter\">"  + (XtopCenter.toFloat()/rezWidth).format("%.06f")    + "</string>  <!--   Center Line Top     ->   (pixels_" + XtopCenter.toFloat().format("%.1f")                                                    + ")                        / w_"  + rezWidth + " = " + (XtopCenter.toFloat()/rezWidth).format("%.06f")  +  " -->");
			System.println("    <string id=\"oXtopOffsets\">" + (XtopOffsets.toFloat()/rezWidth).format("%.06f")   + "</string>  <!--  Margin to Center**   ->   (pixels_" + XtopOffsets.toFloat().format("%.1f")                                                  + ")                         / w_"  + rezWidth + " = " + (XtopOffsets.toFloat()/rezWidth).format("%.06f") + "  -->");
			System.println("");
			System.println("    <string id=\"oYlbl_GF\">"     + (oYlbl_GF.toFloat()/dcHeight).format("%.06f")  + "</string>      <!--   Labels Deg & SLD    ->   (pixels_" + (oYlbl_GF - xt0Mid).format("%.1f") + " + xt0Mid_" + xt0Mid.format("%.1f") +  " )_" + oYlbl_GF.format("%.1f") +  "    / h_"  + dcHeight + " = " + (oYlbl_GF.toFloat()/dcHeight).format("%.06f")    + "  -->");
			System.println("    <string id=\"oYdat_GF\">"     + (oYdat_GF.toFloat()/dcHeight).format("%.06f")  + "</string>      <!--    Data Deg & SLD     ->   (pixels_" + (oYdat_GF - md6Mid).format("%.1f") + " + md6Mid_" + md6Mid.format("%.1f") +  " )_" + oYdat_GF.format("%.1f") +   "   / h_"  + dcHeight + " = " + (oYdat_GF.toFloat()/dcHeight).format("%.06f")    + "  -->");
			System.println("");
			System.println("    <string id=\"oY_____1\">"     + (oY_____1.toFloat()/dcHeight).format("%.06f")   + "</string>      <!--       Top Line        ->   (pixels_" + oY_____1.format("%.1f")                                                        + ")                       / h_"  + dcHeight + " = " + (oY_____1.toFloat()/dcHeight).format("%.06f")     + "  -->");
			System.println("    <string id=\"oYlbl_PHT\">"    + (oYlbl_PHT.toFloat()/dcHeight).format("%.06f")  + "</string>     <!--  Labels HR Alt Pace   ->   (pixels_" + (oYlbl_PHT - xt0Mid).format("%.1f") + " + xt0Mid_" + xt0Mid.format("%.1f") + "  )_" + oYlbl_PHT.format("%.1f") +   " / h_"  + dcHeight + " = " + (oYlbl_PHT.toFloat()/dcHeight).format("%.06f")   + "  -->");
			System.println("    <string id=\"oYdat_PHT\">"    + (oYdat_PHT.toFloat()/dcHeight).format("%.06f")  + "</string>     <!--   Data HR Alt Pace    ->   (pixels_" + (oYdat_PHT - lg4Mid).format("%.1f") + " + lg4Mid_" + lg4Mid.format("%.1f") +  " )_" + oYdat_PHT.format("%.1f")  + "  / h_"  + dcHeight + " = " + (oYdat_PHT.toFloat()/dcHeight).format("%.06f")   + "  -->");
			System.println("");
			System.println("    <string id=\"oY_____2\">"     + (oY_____2.toFloat()/dcHeight).format("%.06f")  +  "</string>      <!--   Mid Line (thin)     ->   (pixels_" + oY_____2.format("%.1f")                                                        + ")                       / h_"  + dcHeight + " = " + (oY_____2.toFloat()/dcHeight).format("%.06f")     + "  -->");
			System.println("    <string id=\"oYdat_TS\">"     + (oYdat_TS.toFloat()/dcHeight).format("%.06f")  + "</string>      <!--  Data Timer & Dist    ->   (pixels_" + (oYdat_TS - lg4Mid).format("%.1f") + " + lg4Mid_" + lg4Mid.format("%.1f") +    " )_" + oYdat_TS.format("%.1f")  + "  / h_"  + dcHeight + " = " + (oYdat_TS.toFloat()/dcHeight).format("%.06f")    + "  -->");
			System.println("    <string id=\"oYlbl_TS\">"     + (oYlbl_TS.toFloat()/dcHeight).format("%.06f")  + "</string>      <!-- Labels Timer & Dist   ->   (pixels_" + (oYlbl_TS - xt0Mid).format("%.1f") + " + xt0Mid_" + xt0Mid.format("%.1f") +   "  )_" + oYlbl_TS.format("%.1f")  + " / h_"  + dcHeight + " = " + (oYlbl_TS.toFloat()/dcHeight).format("%.06f")    + "  -->");
			System.println("");
			System.println("    <string id=\"oY_____3\">"     + (oY_____3.toFloat()/dcHeight).format("%.06f")  +  "</string>      <!--     Bottom Line       ->   (pixels_" + oY_____3.format("%.1f")                                                        + ")                       / h_"  + dcHeight + " = " + (oY_____3.toFloat()/dcHeight).format("%.06f")     + "  -->");
			System.println("    <string id=\"oYdat_BT\">"     + (oYdat_BT.toFloat()/dcHeight).format("%.06f")  + "</string>      <!--   Data Batt & Tod     ->   (pixels_" + (oYdat_BT - xt0Mid).format("%.1f") + " + xt0Mid_" + xt0Mid.format("%.1f") +  "  )_" + oYdat_BT.format("%.1f")   +  " / h_"  + dcHeight + " = " + (oYdat_BT.toFloat()/dcHeight).format("%.06f")    + "  -->");
			System.println("");
			System.println("    <string id=\"oXbtmCenter\">"  + (XbtmCenter.toFloat()/rezWidth).format("%.06f")   +  "</string>  <!--    Center Line Btm    ->   (pixels_" + XbtmCenter.toFloat().format("%.1f")                                                     + ")                       / w_"  + rezWidth + " = " + (XbtmCenter.toFloat()/rezWidth).format("%.06f")  +  " -->");
			System.println("    <string id=\"oXbtmOffsets\">" + (XbtmOffsets.toFloat()/rezWidth).format("%.06f")   + "</string>  <!--  Margin to Ctr/Edge** ->   (pixels_" + XbtmOffsets.toFloat().format("%.1f")                                                  + ")                         / w_"  + rezWidth + " = " + (XbtmOffsets.toFloat()/rezWidth).format("%.06f") + "  -->");
			System.println("    <!-- ** on rect devices, Ylbl_GF & Ydat_BT are both edge-justified and use 'Margin to Ctr/Edge**'; on round, Ylbl_GF uses 'Margin to Center**' -->"); // perhaps change this next Mike...
			System.println("");
			System.println("</resources>");
			System.print("<!-- ============================================================ ");
			System.println(getModelIdentifier() + "  device tested: XXXXXX  -->");
		}
    }
	// -------------------------------------------------------------------------------------------------------------------
	function getModelIdentifier() {
		var settings = System.getDeviceSettings();
		if (settings has :partNumber) {
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
		// backcol = Gfx.COLOR_WHITE;
		// forecol = Gfx.COLOR_BLACK;
    	
		backcol = Gfx.COLOR_BLACK;	// dark mode (normal for production) // mike note: initialize color settings
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
        dc.setColor(Gfx.COLOR_WHITE, backcol); // this should work normally; if not check simulator "data fields -> background color -> black" if weird white areas showing up on simulator
        dc.clear(); // paint background color
        
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3); // set foreground color linecol for printing lines, text
        
        // Draw the BOLD lines 
        dc.drawLine( 0, oY_____1, rezWidth, oY_____1);         // Top horizontal 
        dc.drawLine( topCenter, oY_____1, topCenter, 0 );     // Top vertical split-line
        dc.drawLine( 0, oY_____3, rezWidth, oY_____3);         // Bottom horizontal 
        
        // Draw the thin middle lines 
        dc.setPenWidth(1);
        dc.drawLine( 0, oY_____2, rezWidth, oY_____2 );                    // Middle horizontal 
        dc.drawLine( middlew, oY_____1, middlew, oY_____2 );             // HR/Alt vertical split-line 
        dc.drawLine( 2 * middlew, oY_____1, 2 * middlew, oY_____2 );     // Alt/Pace vertical split-line
        
        dc.drawLine( halfWitt, oY_____2, halfWitt, oY_____3 );           // Timer/Dist vertical split-line
        
        dc.drawLine( bottomCenter, oY_____3, bottomCenter, dc.getHeight() );  // Battery/Time vertical split-line
        dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
		
        // ---------- ////////////////////////////////////
        // TOP fields ////////////////////////////////////
        // ---------- ////////////////////////////////////
        
		// mike note: top left - Deg / slb - degrees bearing (in RED medium font)
        dcdrawText( dc, slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, topAlign1 );
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        dcdrawText( dc, slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), topAlign2 );
        
		// mike note: top right - SLD straight-line distance in ft or m (in med font)
		dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
        dcdrawText( dc, sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, topAlign3 );
        dcdrawText( dc, sldX2, sldY2, Gfx.FONT_NUMBER_MEDIUM, getSld(), topAlign4 );
        
        // ------------- ////////////////////////////////////
        // MIDDLE fields ////////////////////////////////////
        // ------------- ////////////////////////////////////
		var midfont = Gfx.FONT_LARGE;

		// mike note: middle left - heart rate in bpm
		var hrString = (core.heart != null ? core.heart.toString() : "");
        dcdrawText( dc, halfMiddleWidth, oYlbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dcdrawText( dc, halfMiddleWidth, oYdat_PHT, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: middle center - altitude with unit conversion
        dcdrawText( dc, altX, oYlbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER );
        var altNum = getAlt();
        if (altNum > 9999) { // mike note: if elevation over 9999 (10k ft or m?), use smaller font (med instead of large)
        	dcdrawText( dc, altX, 100, Gfx.FONT_MEDIUM, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        	dcdrawText( dc, altX, oYdat_PHT, midfont, altNum.toString(), Gfx.TEXT_JUSTIFY_CENTER );
        }
        
		// mike note: middle right - pace with unit conversion
        dcdrawText( dc, paceX, oYlbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER );
        dcdrawText( dc, paceX, oYdat_PHT, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER ); 					
        
        // ------- // mike note: lower half of middle fields 
        
		// mike note: lower middle left - elapsed activity time, formatted
        dcdrawText( dc, tidX, oYdat_TS, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER );
        dcdrawText( dc, tidX, oYlbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
		// mike note: lower middle right - converted activity distance total (does not reset upon new lap)
        dcdrawText( dc, distX, oYdat_TS, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER );
        dcdrawText( dc, distX, oYlbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER );
        
        // ------------- ////////////////////////////////////
        // Bottom fields ////////////////////////////////////
        // ------------- ////////////////////////////////////
        
		// mike note: time of day HH:MM:SS
		dcdrawText( dc, todX, oYdat_BT, Gfx.FONT_XTINY, getTod(), bottomAlign2); //Gfx.TEXT_JUSTIFY_LEFT );
        
		// mike note: battery percentage, writing in different color depending upon percentage
        var batt = Sys.getSystemStats().battery.toNumber();
        setBatteryColor(dc, batt);
        dcdrawText( dc, battX, oYdat_BT, Gfx.FONT_XTINY, batt + "%", bottomAlign1); // Gfx.TEXT_JUSTIFY_RIGHT);

		if (DEBUG_PRINT_MIDLINES) {
			drawMidLines(dc, slbY1); //oYlbl_GF); 
			drawMidLines(dc, slbY2); //oYdat_GF);
			drawMidLines(dc, oYlbl_PHT);
			drawMidLines(dc, oYdat_PHT);
			drawMidLines(dc, oYdat_TS);
			drawMidLines(dc, oYlbl_TS);
			drawMidLines(dc, oYdat_BT);
		}

		// mike note: for testing memory
		System.println(memstr());
	}
	// mike note: for testing memory
	function memstr () { return ((Toybox.System.getSystemStats().freeMemory.toFloat()/Toybox.System.getSystemStats().totalMemory.toFloat()) * 100).toNumber() + "% available"; } 
	// -------------------------------------------------------------------------------------------------------------------
	function drawMidLines(dc, y) {
		dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
	    dc.setPenWidth(1); 
		dc.drawLine( 0, y, dc.getWidth(), y );
		dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
	}
	// -------------------------------------------------------------------------------------------------------------------
    function dcdrawText(dc, x, y, font, text, justification){
		
		// attempt to undo mid for each text location... 
		var undoMid = 0;
		if (font == Gfx.FONT_XTINY) {
			undoMid = xt0Mid;
		} else if (font == Gfx.FONT_LARGE) {
			undoMid = lg4Mid;
		} else if (font == Gfx.FONT_NUMBER_MEDIUM) {
			undoMid = md6Mid;
		}
		
		// print text
		dc.drawText(x, y - undoMid, font, text, justification);

		if ( false ) { // if true, shows text outlines in yellow for debug purposes

			// change to highlight red for justification
			dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
		    dc.setPenWidth(3); 
		
			// get dimensions array [width, height] and calculate justification
    		var size = dc.getTextDimensions(text, font);
			var justifiedX = x;
			if (justification == Gfx.TEXT_JUSTIFY_LEFT) {
				dc.drawLine( x, y, x, y + size[1] );
			} else if (justification == Gfx.TEXT_JUSTIFY_CENTER) {
				justifiedX = x - (size[0]/2);
				dc.drawLine( x, y, x, y + size[1] );
			} else if (justification == Gfx.TEXT_JUSTIFY_RIGHT) {
				justifiedX = x - size[0];
				dc.drawLine( x, y, x, y + size[1] );
			}

			// change to highlight color, yellow
			dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
		    dc.setPenWidth(1); 

			// need to use special procedure to determine more accurate font height boxes: (steps 1-4)
			
			// 1. get the raw unadjusted text dimensions
			var rawWidth = size[0];
			var rawHeight = size[1];

			// 2. determine closer estimate of font height using your heuristic
			var ascent = Gfx.getFontAscent(font);
			var descent = Gfx.getFontDescent(font);
			var accurateHeight = ascent; 
			if (descent != 0) {
				// True visual height calculation
				accurateHeight = (ascent + descent) * 0.78; 		
			}

			// 3. calculate the Y-position correction. We subtract the accurate height 
			// from the raw block height to find the leftover padding space. Splitting 
			// this remainder by 2 centers the bounding box vertically over the glyphs.
			var totalPadding = rawHeight - accurateHeight;
			var visualY = y + (totalPadding / 2);

			// 4. use 'justifiedX' and 'rawWidth' for horizontal data, and the adjusted 'visualY' and 'accurateHeight' for vertical data.
			dc.drawRectangle(justifiedX, visualY, rawWidth, accurateHeight);

			// debug purposes show accurateHeight of font
			//System.println("     ** accurateHeight of font '" + font + "' is " + accurateHeight);

			// change color to forecol
			dc.setColor( forecol, Gfx.COLOR_TRANSPARENT );
		}
	}
// ======================================================================================================================
}
// notes below, class ends here