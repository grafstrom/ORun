using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Activity as Act;
using Toybox.Graphics as Gfx;

class ORunView extends Ui.DataField {


	// pixel Values EITHER calculated backwards from ratio values or loaded direct from resources.xml
	var XtopCenter;
	var XtopOffsets;
	var Ylbl_GF;
	var Ydat_GF;
	var Y_____1;
	var Ylbl_PHT;
	var Ydat_PHT;
	var Y_____2;
	var Ylbl_TS;
	var Ydat_TS;
	var Y_____3;
	var Ydat_BT;
	var XbtmCenter;
	var XbtmOffsets;

	// ratio values EITHER LOADED FROM RESOURCES OR CALCULATED FROM NON-RATIO VALUES
	var oXtopCenter;
	var oXtopOffsets;
	var oYlbl_GF; 
	var oYdat_GF;
	var oY_____1;
	var oYlbl_PHT;
	var oYdat_PHT;
	var oY_____2;
	var oYdat_TS;
	var oYlbl_TS;
	var oY_____3;
	var oYdat_BT;
	var oXbtmCenter;
	var oXbtmOffsets;

	// mid-point offsets for xTiny, large and medium fonts, different per device
	var xt0Mid;
	var lg4Mid;
	var md6Mid;

	// mid-point values
	var mYlbl_GF; 
	var mYdat_GF;
	var mYlbl_PHT;
	var mYdat_PHT;
	var mYdat_TS;
	var mYlbl_TS;
	var mYdat_BT;
	var mXtopCenter;
	var mXtopOffsets;
	var mXbtmCenter;
	var mXbtmOffsets;

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
		var xt0Acc = Gfx.getFontAscent(Gfx.FONT_XTINY);
		if (Gfx.getFontDescent(Gfx.FONT_XTINY) != 0) {
			xt0Acc = (Gfx.getFontAscent(Gfx.FONT_XTINY) + Gfx.getFontDescent(Gfx.FONT_XTINY)) * 0.78;
		}
		var lg4Acc = Gfx.getFontAscent(Gfx.FONT_LARGE);
		if (Gfx.getFontDescent(Gfx.FONT_LARGE) != 0) {
			lg4Acc = (Gfx.getFontAscent(Gfx.FONT_LARGE) + Gfx.getFontDescent(Gfx.FONT_LARGE)) * 0.78;
		}
		var md6Acc = Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM);
		if (Gfx.getFontDescent(Gfx.FONT_NUMBER_MEDIUM) != 0) {
			md6Acc = (Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM) + Gfx.getFontDescent(Gfx.FONT_NUMBER_MEDIUM)) * 0.78;
		}
		
		// 3. Find where the visual top of the numbers actually starts inside the raw block
		//var TopPadding = (getFontHeight - accurateHeight) / 2;
		var xt0TopPadding = ((dc.getFontHeight(Gfx.FONT_XTINY) - xt0Acc) / 2.0).toFloat(); // 
		var lg4TopPadding = ((dc.getFontHeight(Gfx.FONT_LARGE) - lg4Acc) / 2.0).toFloat(); // 
		var md6TopPadding = ((dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) - md6Acc) / 2.0).toFloat(); // 
		//System.println("   TopPaddings are xt0TopPadding_" + xt0TopPadding.format("%.1f") + ", lg4TopPadding_" + lg4TopPadding.format("%.1f") + ", md6TopPadding_" + md6TopPadding.format("%.1f"));

		xt0Mid = xt0TopPadding + (xt0Acc/2).toFloat(); // 
		lg4Mid = lg4TopPadding + (lg4Acc/2).toFloat(); // 
		md6Mid = md6TopPadding + (md6Acc/2).toFloat(); // 
		//System.println("   Mids are xt0Mid_" + xt0Mid.format("%.1f") + ", lg4Mid_" + lg4Mid.format("%.1f") + ", md6Mid_" + md6Mid.format("%.1f") + " // add to get center line for each: ");
		var rezHeight = dcHeight; // default for round watches, no adjustment of metrics based on switching layouts from 1-2 datafields is allowed


		

		var runFromRatios = Ui.loadResource(Rez.Strings.RunFromRatios).equals("true");
		//System.println("runFromRatios is " + runFromRatios);
		if (!runFromRatios) { //shape != System.SCREEN_SHAPE_RECTANGLE) { 
			// old resources.xml direct metrics processing
			Ylbl_GF = Ui.loadResource(Rez.Strings.Ylbl_GF).toNumber();
			Ydat_GF = Ui.loadResource(Rez.Strings.Ydat_GF).toNumber();
				Y_____1 = Ui.loadResource(Rez.Strings.Y_____1).toNumber();
			Ylbl_PHT = Ui.loadResource(Rez.Strings.Ylbl_PHT).toNumber();
			Ydat_PHT = Ui.loadResource(Rez.Strings.Ydat_PHT).toNumber();
				Y_____2 = Ui.loadResource(Rez.Strings.Y_____2).toNumber();
			Ydat_TS = Ui.loadResource(Rez.Strings.Ydat_TS).toNumber();
			Ylbl_TS = Ui.loadResource(Rez.Strings.Ylbl_TS).toNumber();
				Y_____3 = Ui.loadResource(Rez.Strings.Y_____3).toNumber();
			Ydat_BT = Ui.loadResource(Rez.Strings.Ydat_BT).toNumber();
			
			XtopCenter = Ui.loadResource(Rez.Strings.XtopCenter).toNumber();//toNumber();
			XtopOffsets = Ui.loadResource(Rez.Strings.XtopOffsets).toNumber();//toNumber();
			XbtmCenter = Ui.loadResource(Rez.Strings.XbtmCenter).toNumber();//toNumber();
			XbtmOffsets = Ui.loadResource(Rez.Strings.XbtmOffsets).toNumber();//toNumber();

			
			// 4. Calculate the center line: Start position + Top Padding + Half of the accurateHeight
			mYlbl_GF  = Ylbl_GF  + xt0Mid; 
			mYdat_GF  = Ydat_GF  + md6Mid;
			mYlbl_PHT = Ylbl_PHT + xt0Mid;
			mYdat_PHT = Ydat_PHT + lg4Mid;
			mYdat_TS  = Ydat_TS  + lg4Mid;
			mYlbl_TS  = Ylbl_TS  + xt0Mid;
			mYdat_BT  = Ydat_BT  + xt0Mid;

			// sample desired output
			//System.println("    <string id=\"oYlbl_GF\">" + (mYlbl_GF.toFloat()/dcHeight).format("%.3f") + "</string>     <!--  Labels Deg & SLD     ( pixels_" + Ylbl_GF + " + xt0Mid_" + xt0Mid + " )_" + mYlbl_GF.format("%.1f") + " / h_" + rezHeight + " = " + mYlbl_GF.toFloat()/dcHeight.format("%.3f") + "-->");

			// round/semi-octagon default: no ratio resources yet, use midpoint-adjusted pixels directly
			oY_____1 = Y_____1;
			oY_____2 = Y_____2;
			oY_____3 = Y_____3;
			oYlbl_GF = mYlbl_GF;
			oYdat_GF = mYdat_GF;
			oYlbl_PHT = mYlbl_PHT;
			oYdat_PHT = mYdat_PHT;
			oYdat_TS = mYdat_TS;
			oYlbl_TS = mYlbl_TS;
			oYdat_BT = mYdat_BT;

			oXtopCenter = XtopCenter.toFloat(); // no adjustment because no "mid point" for this text - these are the x values
			oXtopOffsets = XtopOffsets.toFloat();
			oXbtmCenter = XbtmCenter.toFloat();
			oXbtmOffsets = XbtmOffsets.toFloat();
		} else { // if runFromRatios
			
			rezHeight = dc.getHeight(); //Ui.loadResource(Rez.Strings.height).toNumber(); 
			if (shape == System.SCREEN_SHAPE_RECTANGLE) {
				dcHeight = dc.getHeight(); // only rectangle devices are allowed to adjust height of positioning based on user switching to different layout, i.e., 1-2 datafields
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


			XtopCenter = (oXtopCenter * rezWidth).toNumber(); //these are the pixel values, calculated from ratios in resources
			XtopOffsets = (oXtopOffsets * rezWidth).toNumber();
			XbtmCenter = (oXbtmCenter * rezWidth).toNumber();
			XbtmOffsets = (oXbtmOffsets * rezWidth).toNumber();


			mYlbl_GF = oYlbl_GF;
			mYdat_GF = oYdat_GF;
			mYlbl_PHT = oYlbl_PHT;
			mYdat_PHT = oYdat_PHT;
			mYdat_TS = oYdat_TS;
			mYlbl_TS = oYlbl_TS;
			mYdat_BT = oYdat_BT;
			Y_____1 = oY_____1.toNumber();
			Y_____2 = oY_____2.toNumber();
			Y_____3 = oY_____3.toNumber();

			Ylbl_GF  = (mYlbl_GF  - xt0Mid).toNumber(); 
			Ydat_GF  = (mYdat_GF  - md6Mid).toNumber();
			Ylbl_PHT = (mYlbl_PHT - xt0Mid).toNumber();
			Ydat_PHT = (mYdat_PHT - lg4Mid).toNumber();
			Ydat_TS  = (mYdat_TS  - lg4Mid).toNumber();
			Ylbl_TS  = (mYlbl_TS  - xt0Mid).toNumber();
			Ydat_BT  = (mYdat_BT  - xt0Mid).toNumber();
		}




		halfWitt = rezWidth / 2;
		middlew = rezWidth / 3;
		halfMiddleWidth = middlew / 2;
		altX = middlew + halfMiddleWidth;
		tidX = (halfWitt / 2) + 5;
		distX = (3 * halfWitt / 2) - 5;
		paceX = 2 * middlew + halfMiddleWidth;
		
		var deviceme = Ui.loadResource(Rez.Strings.device);

		if (!runFromRatios) { //shape != System.SCREEN_SHAPE_RECTANGLE) { 
			//System.println("not running from ratios - Device:" + deviceme + "     (dcHeight:" + dc.getHeight() + " dcWidth:" + dc.getWidth() + ") ");

			// contains code that previously applied only to round watches

			topCenter = halfWitt + XtopCenter;    // X adjustment from middle of top vertical line
			bottomCenter = halfWitt + XbtmCenter; // X adjustment from middle of bottom vertical line
			todX = bottomCenter + XbtmOffsets;        // X adjustment from bottom vertical for time-of-day
			battX = bottomCenter - XbtmOffsets;      // X adjustment from bottom vertical for battery pct
		
			// default for round layout  (rezShape == System.SCREEN_SHAPE_ROUND)
			slbX1 = topCenter - XtopOffsets;
			slbY1 = mYlbl_GF;
			slbX2 = topCenter - XtopOffsets;
			slbY2 = mYdat_GF;
			sldX1 = topCenter + XtopOffsets;
			sldY1 = mYlbl_GF;
			sldX2 = topCenter + XtopOffsets;
			sldY2 = mYdat_GF;

			// default align for round layout  (rezShape == System.SCREEN_SHAPE_ROUND)
			topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
			topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
			topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
			bottomAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
			bottomAlign2 = Gfx.TEXT_JUSTIFY_LEFT;

			if (System has :SCREEN_SHAPE_SEMI_OCTAGON){ // first confirm that watch recognizes the terminology octagonal
				// if (shape == System.SCREEN_SHAPE_SEMI_OCTAGON) {
				// 	if (!rezShape.equals("semioctagon")) {
				// 		Sys.println("ERROR: System.getDeviceSettings().screenShape does not match Ui.loadResource(Rez.Strings.shape)");
				// 	}
				// 	// get dimensions, center of small circular screen at top right
				// 	var subscreenInfo = WatchUi.getSubscreen();
				// 	var x, y, width, height, centerX, centerY;

				// 	if (subscreenInfo != null) {
				// 		x = subscreenInfo.x;
				// 		y = subscreenInfo.y;
				// 		width = subscreenInfo.width;
				// 		height = subscreenInfo.height;
				// 		// Calculate center coordinates for printing text
				// 		centerX = x + (width / 2);
				// 		centerY = y + (height / 2);
				// 	}
					
				// 	// slb/bearing from lap/start		 
				// 	slbX1 = topCenter + XtopOffsets; // Switch add/subtract so bearing appears in the smaller circle, raise
				// 	slbY1 = mYlbl_GF;
				// 	slbX2 = topCenter + XtopOffsets;
				// 	slbY2 = mYdat_GF; // - 20; // so bearing appears raised... 20 pixels higher than dist on left side..

				// 	// sld/distance from lap/start
				// 	sldX1 = topCenter - XtopOffsets;
				// 	sldY1 = mYlbl_GF;
				// 	sldX2 = topCenter - XtopOffsets;
				// 	sldY2 = mYdat_GF;
				// } 
			}
		} else { // if (runFromRatios)
		
			topCenter = halfWitt + (oXtopCenter * rezWidth);    // X adjustment from middle of top vertical line
	    	bottomCenter = halfWitt + (oXbtmCenter * rezWidth); // X adjustment from middle of bottom vertical line

			slbX2 = topCenter - (oXtopOffsets * rezWidth); // dat is still center-justified for all devices
			sldX2 = topCenter + (oXtopOffsets * rezWidth); // dat is still center-justified for all devices

			slbY1 = oYlbl_GF;
			slbY2 = oYdat_GF;
			sldY1 = oYlbl_GF;
			sldY2 = oYdat_GF;

			// handle top label (slb, sld), and bottom data (batt, tod) margin and justification
			if (shape == System.SCREEN_SHAPE_RECTANGLE) { 
				// on rectangle devices, tld and tlb (at top), and batt & tod (at bottom) are SIDE-EDGE-justified
				slbX1 = (oXbtmOffsets * rezWidth); 					// use SAME as BOTTOM offset distance for slb label
				sldX1 = rezWidth - 2 - (oXbtmOffsets * rezWidth);   // use SAME as BOTTOM offset distance for slD label
				battX = (oXbtmOffsets * rezWidth);
				todX  = rezWidth - 2 - (oXbtmOffsets * rezWidth);
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
				slbX1 = topCenter - (oXtopOffsets * rezWidth);
				sldX1 = topCenter + (oXtopOffsets * rezWidth);
				battX = bottomCenter - (oXbtmOffsets * rezWidth);
				todX  = bottomCenter + (oXbtmOffsets * rezWidth);
				// on round devices, tld and tlb (at top), and batt & tod (at bottom) are CENTER-justified
				topAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
				topAlign2 = Gfx.TEXT_JUSTIFY_RIGHT;
				topAlign3 = Gfx.TEXT_JUSTIFY_LEFT;
				topAlign4 = Gfx.TEXT_JUSTIFY_LEFT;
				bottomAlign1 = Gfx.TEXT_JUSTIFY_RIGHT;
				bottomAlign2 = Gfx.TEXT_JUSTIFY_LEFT;
			}
		} 
		
		// System.print("..");
		// if (mYlbl_GF instanceof Lang.Float) {
		// 	System.println("mYlbl_GF is float"); 
		// } else if (mYlbl_GF instanceof Lang.Number) {
		// 	System.println("mYlbl_GF is number");
		// }
		// System.print("...");
		// if (Ylbl_GF instanceof Lang.Float) {
		// 	System.println("Ylbl_GF is float"); 
		// } else if (Ylbl_GF instanceof Lang.Number) {
		// 	System.println("Ylbl_GF is number");
		// }
		// System.print("....");
		// if ((xt0Mid.toFloat()/rezWidth) instanceof Lang.Float) {
		// 	System.println("(xt0Mid.toFloat()/rezWidth) is float"); 
		// } else if ((xt0Mid.toFloat()/rezWidth) instanceof Lang.Number) {
		// 	System.println("(xt0Mid.toFloat()/rezWidth) is number");
		// }
		// System.print(".....");
		// if ((XtopCenter.toFloat()/rezWidth) instanceof Lang.Float) {
		// 	System.println("(XtopCenter.toFloat()/rezWidth) is float");
		// } else if ((XtopCenter.toFloat()/rezWidth) instanceof Lang.Number) {
		// 	System.println("(XtopCenter.toFloat()/rezWidth) is number");
		// }		


		// debug printlns for producing ratio output for resources.xml files
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
		logFontMetrics(dc); //  SEE logFontMetrics TO EDIT FONT OUTPUT HERE... (AT TOP OF FILE)
		System.println("");
		System.println("    <!-- NOTE: the more times the ratios are converted using vscode, the more it will shift smaller and smaller (up and up on screen) due to subtle math conversions -->");
		System.println("    <!-- So simply only run it once, and update your resources.xml file for each device, and be done with it.  Each extra run may decrease pixels by 1-2? -->");"
		System.println("");
		System.println("    <string id=\"oXtopCenter\">"  + (XtopCenter.toFloat()/rezWidth).format("%.03f")    + "</string>  <!--   Center Line Top     ->   (pixels_" + XtopCenter.format("%3d") + ")                      / w_"                                                     + rezWidth + " = " + (XtopCenter.toFloat()/rezWidth).format("%.03f")  + " -->");
		System.println("    <string id=\"oXtopOffsets\">" + (XtopOffsets.toFloat()/rezWidth).format("%.03f")   + "</string>  <!--  Margin to Center**   ->   (pixels_" + XtopOffsets.format("%3d") + ")                      / w_"                                                    + rezWidth + " = " + (XtopOffsets.toFloat()/rezWidth).format("%.03f") + " -->");
		System.println("");
		System.println("    <string id=\"oYlbl_GF\">"     + (mYlbl_GF.toFloat()/dcHeight).format("%.03f")  + "</string>      <!--   Labels Deg & SLD    ->   (pixels_" + Ylbl_GF.format("%3d") + " + xt0Mid_" + xt0Mid.format("%.1f") +   " )_" + mYlbl_GF.format("%.1f") + "   / h_" + dcHeight + " = " + (mYlbl_GF.toFloat()/dcHeight).format("%.03f")    + " -->");
		System.println("    <string id=\"oYdat_GF\">"     + (mYdat_GF.toFloat()/dcHeight).format("%.03f")  + "</string>      <!--    Data Deg & SLD     ->   (pixels_" + Ydat_GF.format("%3d") + " + md6Mid_" + md6Mid.format("%.1f") +   " )_" + mYdat_GF.format("%.1f") + "  / h_"  + dcHeight + " = " + (mYdat_GF.toFloat()/dcHeight).format("%.03f")    + " -->");
		System.println("");
		System.println("    <string id=\"oY_____1\">"     + (Y_____1.toFloat()/dcHeight).format("%.03f")   + "</string>      <!--       Top Line        ->   (pixels_" + Y_____1.format("%3d") + ")                      / h_"                                                        + dcHeight + " = " + (Y_____1.toFloat()/dcHeight).format("%.03f")     + " -->");
		System.println("    <string id=\"oYlbl_PHT\">"    + (mYlbl_PHT.toFloat()/dcHeight).format("%.03f")  + "</string>     <!--  Labels HR Alt Pace   ->   (pixels_" + Ylbl_PHT.format("%3d") + " + xt0Mid_" + xt0Mid.format("%.1f") + "  )_" + mYlbl_PHT.format("%.1f") + " / h_"  + dcHeight + " = " + (mYlbl_PHT.toFloat()/dcHeight).format("%.03f")   + " -->");
		System.println("    <string id=\"oYdat_PHT\">"    + (mYdat_PHT.toFloat()/dcHeight).format("%.03f")  + "</string>     <!--   Data HR Alt Pace    ->   (pixels_" + Ydat_PHT.format("%3d") + " + lg4Mid_" + lg4Mid.format("%.1f") +  " )_" + mYdat_PHT.format("%.1f") + " / h_"  + dcHeight + " = " + (mYdat_PHT.toFloat()/dcHeight).format("%.03f")   + " -->");
		System.println("");
		System.println("    <string id=\"oY_____2\">"     + (Y_____2.toFloat()/dcHeight).format("%.03f")  +  "</string>      <!--   Mid Line (thin)     ->   (pixels_" + Y_____2.format("%3d") + ")                      / h_"                                                        + dcHeight + " = " + (Y_____2.toFloat()/dcHeight).format("%.03f")     + " -->");
		System.println("    <string id=\"oYdat_TS\">"     + (mYdat_TS.toFloat()/dcHeight).format("%.03f")  + "</string>      <!--  Data Timer & Dist    ->   (pixels_" + Ydat_TS.format("%3d") + " + lg4Mid_" + lg4Mid.format("%.1f") +   " )_" + mYdat_TS.format("%.1f")  + " / h_"  + dcHeight + " = " + (mYdat_TS.toFloat()/dcHeight).format("%.03f")    + " -->");
		System.println("    <string id=\"oYlbl_TS\">"     + (mYlbl_TS.toFloat()/dcHeight).format("%.03f")  + "</string>      <!-- Labels Timer & Dist   ->   (pixels_" + Ylbl_TS.format("%3d") + " + xt0Mid_" + xt0Mid.format("%.1f") +  "  )_" + mYlbl_TS.format("%.1f")  + " / h_"  + dcHeight + " = " + (mYlbl_TS.toFloat()/dcHeight).format("%.03f")    + " -->");
		System.println("");
		System.println("    <string id=\"oY_____3\">"     + (Y_____3.toFloat()/dcHeight).format("%.03f")  +  "</string>      <!--     Bottom Line       ->   (pixels_" + Y_____3.format("%3d") + ")                      / h_"                                                        + dcHeight + " = " + (Y_____3.toFloat()/dcHeight).format("%.03f")     + " -->");
		System.println("    <string id=\"oYdat_BT\">"     + (mYdat_BT.toFloat()/dcHeight).format("%.03f")  + "</string>      <!--   Data Batt & Tod     ->   (pixels_" + Ydat_BT.format("%3d") + " + xt0Mid_" + xt0Mid.format("%.1f") +  "  )_" + mYdat_BT.format("%.1f")  + " / h_"  + dcHeight + " = " + (mYdat_BT.toFloat()/dcHeight).format("%.03f")    + " -->");
		System.println("");
		System.println("    <string id=\"oXbtmCenter\">"  + (XbtmCenter.toFloat()/rezWidth).format("%.03f")   +  "</string>  <!--    Center Line Btm    ->   (pixels_" + XbtmCenter.format("%3d") + ")                      / w_"                                                     + rezWidth + " = " + (XbtmCenter.toFloat()/rezWidth).format("%.03f")  + " -->");
		System.println("    <string id=\"oXbtmOffsets\">" + (XbtmOffsets.toFloat()/rezWidth).format("%.03f")   + "</string>  <!--  Margin to Ctr/Edge** ->   (pixels_" + XbtmOffsets.format("%3d") + ")                      / w_"                                                    + rezWidth + " = " + (XbtmOffsets.toFloat()/rezWidth).format("%.03f") + " -->");
		System.println("    <!-- ** on rect devices, Ylbl_GF & Ydat_BT are both edge-justified and use 'Margin to Ctr/Edge**'; on round, Ylbl_GF uses 'Margin to Center**' -->"); // perhaps change this next Mike...
		System.println("");
		System.println("</resources>\n");
		System.print("<!-- ============================================================ ");
		System.println(getModelIdentifier() + "  device tested: XXXXXX  -->");
		
		
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

		// drawMidLines(dc, oYlbl_GF); 
		// drawMidLines(dc, oYdat_GF);
		// drawMidLines(dc, oYlbl_PHT);
		// drawMidLines(dc, oYdat_PHT);
		// drawMidLines(dc, oYdat_TS);
		// drawMidLines(dc, oYlbl_TS);
		// drawMidLines(dc, oYdat_BT);

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
	// -------------------------------------------------------------------------------------------------------------------
    function logFontMetrics(dc){
		var fonts = [ // if additional fonts added
			Gfx.FONT_XTINY,
			Gfx.FONT_LARGE,
			Gfx.FONT_NUMBER_MEDIUM
		];
		var fontnames = [ // need to add additional font names here
			"xt0Acc", // "FONT_XTINY",
			"lg4Acc", // "FONT_LARGE",
			"md6Acc",  // "FONT_NUMBER_MEDIUM"
			"FONT_XTINY",
			"FONT_LARGE",
			"FONT_NUMBER_MEDIUM"
			];

		for (var i = 0; i < fonts.size(); i++) {
			var font = fonts[i];
			
			// get raw system heights
			var rawHeight = dc.getFontHeight(font);
			var ascent = Gfx.getFontAscent(font);
			var descent = Gfx.getFontDescent(font);
			
			// calculate closer visual estimate
			var accurateHeight = ascent; 
			if (descent != 0) {
				accurateHeight = (ascent + descent) * 0.78; 		
			}

			// print metrics directly to the console
			// System.println("    <string id=\"" + fontnames[i] + "\">" + accurateHeight.format("%.3f") + "</string>      <!-- <- accurateHeight of " + fontnames[i+3] + ", whereas getFontHeight()= " + rawHeight + " -->");
			System.println("    <!-- on this device, getFontHeight(Gfx." + fontnames[i+3] + ")=" + rawHeight + " but actually " + accurateHeight.format("%.2f") + " pixels tall -->");
		}
	}
// ======================================================================================================================
}
// notes below, class ends here