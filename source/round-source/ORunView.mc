using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ORunView extends ORunViewBase {

    var oY_____1;
    var oYlbl_GF;
    var oYdat_GF;
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
    var altX;
    var tidX;
    var distX;
    var paceX;
    var todX;
    var battX;

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

        oY_____1 = dcHeight * Ui.loadResource(Rez.Strings.oY_____1).toFloat();
        oYlbl_GF = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_GF).toFloat();
        oYdat_GF = dcHeight * Ui.loadResource(Rez.Strings.oYdat_GF).toFloat();
        oYlbl_PHT = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_PHT).toFloat();
        oYdat_PHT = dcHeight * Ui.loadResource(Rez.Strings.oYdat_PHT).toFloat();
        oY_____2 = dcHeight * Ui.loadResource(Rez.Strings.oY_____2).toFloat();
        oYdat_TS = dcHeight * Ui.loadResource(Rez.Strings.oYdat_TS).toFloat();
        oYlbl_TS = dcHeight * Ui.loadResource(Rez.Strings.oYlbl_TS).toFloat();
        oY_____3 = dcHeight * Ui.loadResource(Rez.Strings.oY_____3).toFloat();
        oYdat_BT = dcHeight * Ui.loadResource(Rez.Strings.oYdat_BT).toFloat();

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
        slbY1 = oYlbl_GF;
        slbY2 = oYdat_GF;
        sldY1 = oYlbl_GF;
        sldY2 = oYdat_GF;
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
        dc.drawLine(0, oY_____1, rezWidth, oY_____1);
        dc.drawLine(topCenter, oY_____1, topCenter, 0);
        dc.drawLine(0, oY_____3, rezWidth, oY_____3);

        // ----------
        // THIN LINES
        // ----------
        dc.setPenWidth(1);
        dc.drawLine(0, oY_____2, rezWidth, oY_____2);
        dc.drawLine(middlew, oY_____1, middlew, oY_____2);
        dc.drawLine(2 * middlew, oY_____1, 2 * middlew, oY_____2);
        dc.drawLine(halfWitt, oY_____2, halfWitt, oY_____3);
        dc.drawLine(bottomCenter, oY_____3, bottomCenter, dc.getHeight());
        
        // ----------
        // TOP FIELDS
        // ----------
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_RIGHT);
        if (notMonochrome) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        dcdrawText(dc, slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_LEFT);
        dcdrawText(dc, sldX2, sldY2, Gfx.FONT_NUMBER_MEDIUM, getSld(), Gfx.TEXT_JUSTIFY_LEFT);

        // --------------------
        // HR, ALT, PACE FIELDS
        // --------------------
        var hrString = core.heart != null ? core.heart.toString() : "";
        dcdrawText(dc, halfMiddleWidth, oYlbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, halfMiddleWidth, oYdat_PHT, Gfx.FONT_LARGE, hrString, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, oYlbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, oYdat_PHT, Gfx.FONT_LARGE, getAlt().toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, oYlbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, oYdat_PHT, Gfx.FONT_LARGE, getPace(), Gfx.TEXT_JUSTIFY_CENTER);
        
        // -------------------------
        // TIMER AND DISTANCE FIELDS
        // -------------------------
        dcdrawText(dc, tidX, oYdat_TS, Gfx.FONT_LARGE, getTid(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, oYlbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, oYdat_TS, Gfx.FONT_LARGE, getDist(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, oYlbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER);
        
        // -------------
        // BOTTOM FIELDS
        // -------------
        dcdrawText(dc, todX, oYdat_BT, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT);

        var battery = Sys.getSystemStats().battery.toNumber();
        if (notMonochrome) {
            setBatteryColor(dc, battery);
        }
        dcdrawText(dc, battX, oYdat_BT, Gfx.FONT_XTINY, battery + "%", Gfx.TEXT_JUSTIFY_RIGHT);

        // -------------------------------
        // OPTIONAL LAYOUT DEBUG MID-LINES
        // -------------------------------
        if (DEBUG_PRINT_MIDLINES) {
            // Draw one green guide for each label and data row from top to bottom.
            drawMidLine(dc, slbY1);
            drawMidLine(dc, slbY2);
            drawMidLine(dc, oYlbl_PHT);
            drawMidLine(dc, oYdat_PHT);
            drawMidLine(dc, oYdat_TS);
            drawMidLine(dc, oYlbl_TS);
            drawMidLine(dc, oYdat_BT);
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