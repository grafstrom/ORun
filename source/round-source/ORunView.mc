using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ORunView extends ORunViewBase {

    // Unlike the legacy view, which selects hard-coded pixel coordinates for a
    // short list of named devices, this round layout stores each text midpoint
    // and divider position as a per-profile ratio of screen size. onLayout scales
    // those resource ratios to the profile width, while shared thirds and halves
    // provide the remaining column centers. The ratios are calibrated for a
    // full-screen square data field, so a smaller multi-field viewport does not
    // trigger a newly calculated arrangement.

    // TODO: Reduce the activity-distance font size when mileage no longer fits inside its grid cell.
    // TODO: Reduce the top-distance font size when it no longer fits
    // (Mike can work on this after a week or so, but will require extra time to check each device)


    var Y_____1; // Y coordinate of the divider below the bearing and straight-line-distance region.
    var Ylbl_GF; // Y center shared by the top bearing and straight-line-distance labels.
    var Ydat_GF; // Y center shared by the top bearing and straight-line-distance values.
    var Ylbl_PHT; // Y center shared by the heart-rate, altitude, and pace labels.
    var Ydat_PHT; // Y center shared by the heart-rate, altitude, and pace values.
    var Y_____2; // Y coordinate of the divider below the heart-rate, altitude, and pace region.
    var Ydat_TS; // Y center shared by the timer and activity-distance values.
    var Ylbl_TS; // Y center shared by the timer and activity-distance labels.
    var Y_____3; // Y coordinate of the divider above the battery and clock region.
    var Ydat_BT; // Y center shared by the battery percentage and clock text.

    var xt0Mid; // Baseline offset that visually centers the extra-tiny font on a Y coordinate.
    var lg4Mid; // Baseline offset that visually centers the large font on a Y coordinate.
    var md6Mid; // Baseline offset that visually centers the number-medium font on a Y coordinate.
    var hotMid; // Baseline offset that visually centers the number-hot font on a Y coordinate.
    var topDataFont = Gfx.FONT_NUMBER_MEDIUM; // Numeric font used for bearing and straight-line distance.
    var rezWidth; // Resource-defined display width used to scale and draw the layout.
    var halfWitt; // Half of the resource-defined display width.
    var middlew; // Width of one column in the three-column middle region.
    var halfMiddleWidth; // Horizontal center of the first middle-region column.
    var topCenter; // X coordinate of the divider between the two top fields.
    var bottomCenter; // X coordinate of the divider between battery and clock text.
    var slbX1; // X anchor for the straight-line-bearing label.
    var slbX2; // X anchor for the straight-line-bearing value.
    var slbY1; // Y center for the straight-line-bearing label.
    var slbY2; // Y center for the straight-line-bearing value.
    var sldX1; // X anchor for the straight-line-distance label.
    var sldX2; // X anchor for the straight-line-distance value.
    var sldY1; // Y center for the straight-line-distance label.
    var sldY2; // Y center for the straight-line-distance value.
    var altX; // X center of the altitude column.
    var tidX; // X center of the elapsed-time field.
    var distX; // X center of the activity-distance field.
    var paceX; // X center of the pace column.
    var todX; // X anchor for the time-of-day text.
    var battX; // X anchor for the battery-percentage text.

    // Draw horizontal guides through every calculated text midpoint for layout calibration.
    const DEBUG_PRINT_MIDLINES = false;

    //! Initialize shared view state before configuring the shape-specific layout.
    function initialize() {
        ORunViewBase.initialize();
    }

    //! Load round-device layout ratios and calculate all text and divider coordinates.
    function onLayout(dc) {
        var dcHeight = dc.getHeight();
        var dcWidth = dc.getWidth();
        rezWidth = Ui.loadResource(Rez.Strings.width).toNumber();
        if (rezWidth != dcWidth) {
            Sys.println("ERROR: dc.getWidth() does not match Ui.loadResource(Rez.Strings.width).toNumber()");
        }

        // Round layouts are calibrated for a full-screen single field. Use the
        // resource-defined square height so multi-field views do not rescale them.
        dcHeight = rezWidth;

        xt0Mid = getFontMid(dc, Gfx.FONT_XTINY);
        lg4Mid = getFontMid(dc, Gfx.FONT_LARGE);
        md6Mid = getFontMid(dc, Gfx.FONT_NUMBER_MEDIUM);
        topDataFont = Gfx.FONT_NUMBER_MEDIUM;
        var device = Ui.loadResource(Rez.Strings.device);
        if (device.equals("round-176x176-crossover")) {
            topDataFont = Gfx.FONT_NUMBER_THAI_HOT;
            hotMid = getFontMid(dc, Gfx.FONT_NUMBER_THAI_HOT);
        }

        Y_____1 = dcHeight * Ui.loadResource(Rez.Strings.oY_____1).toFloat();
        Ylbl_GF = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_GF).toFloat();
        Ydat_GF = dcHeight * Ui.loadResource(Rez.Strings.oYdat_GF).toFloat();
        Ylbl_PHT = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_PHT).toFloat();
        Ydat_PHT = dcHeight * Ui.loadResource(Rez.Strings.oYdat_PHT).toFloat();
        Y_____2 = dcHeight * Ui.loadResource(Rez.Strings.oY_____2).toFloat();
        Ydat_TS = dcHeight * Ui.loadResource(Rez.Strings.oYdat_TS).toFloat();
        Ylbl_TS = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_TS).toFloat();
        Y_____3 = dcHeight * Ui.loadResource(Rez.Strings.oY_____3).toFloat();
        Ydat_BT = dcHeight * Ui.loadResource(Rez.Strings.oYdat_BT).toFloat();

        var topOffset = Ui.loadResource(Rez.Strings.oXtopCenter).toFloat() * rezWidth;
        var bottomOffset = Ui.loadResource(Rez.Strings.oXbtmCenter).toFloat() * rezWidth;
        var topSpacing = Ui.loadResource(Rez.Strings.oXtopOffsets).toFloat() * rezWidth;
        var bottomSpacing = Ui.loadResource(Rez.Strings.oXbtmOffsets).toFloat() * rezWidth;

        halfWitt = rezWidth / 2;
        middlew = rezWidth / 3;
        halfMiddleWidth = middlew / 2;
        altX = middlew + halfMiddleWidth;
        tidX = (halfWitt / 2) + 5;
        distX = (3 * halfWitt / 2) - 5;
        paceX = 2 * middlew + halfMiddleWidth;
        topCenter = halfWitt + topOffset;
        bottomCenter = halfWitt + bottomOffset;

        slbX1 = topCenter - topSpacing;
        slbX2 = topCenter - topSpacing;
        sldX1 = topCenter + topSpacing;
        sldX2 = topCenter + topSpacing;
        battX = bottomCenter - bottomSpacing;
        todX = bottomCenter + bottomSpacing;
        slbY1 = Ylbl_GF;
        slbY2 = Ydat_GF;
        sldY1 = Ylbl_GF;
        sldY2 = Ydat_GF;
    }

    //! Calculate the drawText baseline offset needed to visually center a font.
    function getFontMid(dc, font) {
        var accurateHeight = Gfx.getFontAscent(font).toFloat();
        if (Gfx.getFontDescent(font) != 0) {
            accurateHeight = (Gfx.getFontAscent(font).toFloat() + Gfx.getFontDescent(font).toFloat()) * 0.78;
        }
        var topPadding = (dc.getFontHeight(font).toFloat() - accurateHeight) / 2.0;
        return topPadding + (accurateHeight / 2.0);
    }

    //! Clear and redraw the complete round data-field display.
    function onUpdate(dc) {
        // ----------
        // BACKGROUND
        // ----------
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();

        // -----------
        // THICK LINES
        // -----------
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(0, Y_____1, rezWidth, Y_____1);
        dc.drawLine(topCenter, Y_____1, topCenter, 0);
        dc.drawLine(0, Y_____3, rezWidth, Y_____3);

        // ----------
        // THIN LINES
        // ----------
        dc.setPenWidth(1);
        dc.drawLine(0, Y_____2, rezWidth, Y_____2);
        dc.drawLine(middlew, Y_____1, middlew, Y_____2);
        dc.drawLine(2 * middlew, Y_____1, 2 * middlew, Y_____2);
        dc.drawLine(halfWitt, Y_____2, halfWitt, Y_____3);
        dc.drawLine(bottomCenter, Y_____3, bottomCenter, dc.getHeight());
        
        // ----------
        // TOP FIELDS
        // ----------
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_RIGHT);
        if (notMonochrome) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        dcdrawText(dc, slbX2, slbY2, topDataFont, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_LEFT);
        dcdrawText(dc, sldX2, sldY2, topDataFont, getSld(), Gfx.TEXT_JUSTIFY_LEFT);

        // --------------------
        // HR, ALT, PACE FIELDS
        // --------------------
        var hrString = core.heart != null ? core.heart.toString() : "";
        dcdrawText(dc, halfMiddleWidth, Ylbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, halfMiddleWidth, Ydat_PHT, Gfx.FONT_LARGE, hrString, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, Ylbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, Ydat_PHT, Gfx.FONT_LARGE, getAlt().toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, Ylbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, Ydat_PHT, Gfx.FONT_LARGE, getPace(), Gfx.TEXT_JUSTIFY_CENTER);
        
        // -------------------------
        // TIMER AND DISTANCE FIELDS
        // -------------------------
        dcdrawText(dc, tidX, Ydat_TS, Gfx.FONT_LARGE, getTid(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, Ylbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, Ydat_TS, Gfx.FONT_LARGE, getDist(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, Ylbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER);
        
        // -------------
        // BOTTOM FIELDS
        // -------------
        dcdrawText(dc, todX, Ydat_BT, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT);

        var battery = Sys.getSystemStats().battery.toNumber();
        if (notMonochrome) {
            setBatteryColor(dc, battery);
        }
        dcdrawText(dc, battX, Ydat_BT, Gfx.FONT_XTINY, battery + "%", Gfx.TEXT_JUSTIFY_RIGHT);

        // -------------------------------
        // OPTIONAL LAYOUT DEBUG MID-LINES
        // -------------------------------
        if (DEBUG_PRINT_MIDLINES) {
            // Draw one green guide for each label and data row from top to bottom.
            drawMidLine(dc, slbY1);
            drawMidLine(dc, slbY2);
            drawMidLine(dc, Ylbl_PHT);
            drawMidLine(dc, Ydat_PHT);
            drawMidLine(dc, Ydat_TS);
            drawMidLine(dc, Ylbl_TS);
            drawMidLine(dc, Ydat_BT);
        }
        //Sys.println(memstr()); // checked on instinct2, edge_1000, approachs60 all >40% ok
    }

    //! Draw text with its visual midpoint aligned to the supplied y-coordinate.
    function dcdrawText(dc, x, y, font, text, justification) {
        var mid = lg4Mid;
        if (font == Gfx.FONT_XTINY) {
            mid = xt0Mid;
        } else if (font == Gfx.FONT_NUMBER_MEDIUM) {
            mid = md6Mid;
        } else if (font == Gfx.FONT_NUMBER_THAI_HOT) {
            mid = hotMid;
        }
        dc.drawText(x, y - mid, font, text, justification);
    }

    //! Draw a horizontal guide through a calculated text midpoint.
    function drawMidLine(dc, y) {
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(0, y, dc.getWidth(), y);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }
}