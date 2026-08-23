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
    var tooSmall = false;

    var xt0Mid;
    var sm2Mid;
    var md3Mid;
    var lg4Mid;
    var md6Mid;
    var xt0VisualHeight;
    var sm2VisualHeight;
    var md3VisualHeight;
    var lg4VisualHeight;
    var md6VisualHeight;
    var md6TrimTop;
    var md6TrimBottom;
    var xt0VisualCenterOffset;
    var md6VisualCenterOffset;
    var topDataFont = Gfx.FONT_NUMBER_MEDIUM;
    var lowerDataFont = Gfx.FONT_LARGE;

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

    // Draw measured text bounds and anchor lines when calibrating font placement.
    var debugPrintTextboxes = false;
    // Select one of the seven display rows for isolated midpoint debugging.
    var selectedDebugY = 0;
    // Per-row vertical adjustments: top label/data, middle label/data, timer data/label, bottom.
    var debugYOffset = [0, 0, 0, 0, 0, 0, 0];

    // Draw horizontal guides through calculated text midpoints.
    const DEBUG_PRINT_MIDLINES = false;
    // When midpoint guides are enabled, draw only selectedDebugY instead of all rows.
    const DEBUG_PRINT_ONLY_SELECTED_MIDLINE = false;


    
    const LAYOUT_MIN_GAP = 0.0;
    const TOP_BEARING_CAPACITY = 3.5;
    const TOP_DISTANCE_CAPACITY = 4.0;

    //! Initialize shared view state before configuring the shape-specific layout.
    function initialize() {
        ORunViewBase.initialize();
    }

    //! Measure available fonts and calculate all rectangle layout coordinates.
    function onLayout(dc) {
        var dcHeight = dc.getHeight();
        var dcWidth = dc.getWidth();
        rezWidth = dcWidth;

        var xt0Acc = getVisualHeight(Gfx.FONT_XTINY);
        var sm2Acc = getVisualHeight(Gfx.FONT_SMALL);
        var md3Acc = getVisualHeight(Gfx.FONT_MEDIUM);
        var lg4Acc = getVisualHeight(Gfx.FONT_LARGE);
        var md6Acc = getVisualHeight(Gfx.FONT_NUMBER_MEDIUM);

        var xt0TopPadding = (dc.getFontHeight(Gfx.FONT_XTINY).toFloat() - xt0Acc) / 2.0;
        var sm2TopPadding = (dc.getFontHeight(Gfx.FONT_SMALL).toFloat() - sm2Acc) / 2.0;
        var md3TopPadding = (dc.getFontHeight(Gfx.FONT_MEDIUM).toFloat() - md3Acc) / 2.0;
        var lg4TopPadding = (dc.getFontHeight(Gfx.FONT_LARGE).toFloat() - lg4Acc) / 2.0;
        var md6TopPadding = (dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM).toFloat() - md6Acc) / 2.0;

        var xt0MidShift = Ui.loadResource(Rez.Strings.xt0MidShift).toFloat();
        xt0Mid = xt0TopPadding + (xt0Acc / 2.0) + xt0MidShift;
        xt0VisualCenterOffset = -xt0MidShift;
        sm2Mid = sm2TopPadding + (sm2Acc / 2.0);
        md3Mid = md3TopPadding + (md3Acc / 2.0);
        var lg4MidShift = Ui.loadResource(Rez.Strings.lg4MidShiftRatio).toFloat() * lg4Acc;
        lg4Mid = lg4TopPadding + (lg4Acc / 2.0) + lg4MidShift;
        var md6MidShift = Ui.loadResource(Rez.Strings.md6MidShift).toFloat();
        md6Mid = md6TopPadding + (md6Acc / 2.0) + md6MidShift;
        md6TrimTop = Ui.loadResource(Rez.Strings.md6PadTop).toFloat();
        md6TrimBottom = Ui.loadResource(Rez.Strings.md6PadBot).toFloat();
        md6VisualHeight = Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM).toFloat() - md6TrimTop - md6TrimBottom;
        if (md6VisualHeight < 0) {
            md6VisualHeight = 0;
        }
        md6VisualCenterOffset = ((md6TrimTop - md6TrimBottom) / 2.0) - md6MidShift;
        xt0VisualHeight = xt0Acc;
        sm2VisualHeight = sm2Acc;
        md3VisualHeight = md3Acc;
        lg4VisualHeight = lg4Acc;

        oY_____1 = 0.30 * dcHeight;
        computeDynamicLayout(dcHeight, dcWidth);
        slbY1 = oYlbl_GF;
        slbY2 = oYdat_GF;
        sldY1 = oYlbl_GF;
        sldY2 = oYdat_GF;
    }

    //! Estimate the visible glyph height, excluding excess font-box padding.
    function getVisualHeight(font) {
        var visualHeight = Gfx.getFontAscent(font).toFloat();
        if (Gfx.getFontDescent(font) != 0) {
            visualHeight = (Gfx.getFontAscent(font).toFloat() + Gfx.getFontDescent(font).toFloat()) * 0.78;
        }
        return visualHeight;
    }

    //! Select fonts and derive top and lower field positions from the screen dimensions.
    function computeDynamicLayout(dcHeight, dcWidth) {
        tooSmall = false;
        topDataFont = Gfx.FONT_NUMBER_MEDIUM;
        var topDataVisualHeight = md6VisualHeight;
        var topDataVisualCenterOffset = md6VisualCenterOffset;
        if (topDataVisualHeight > oY_____1) {
            topDataFont = Gfx.FONT_MEDIUM;
            topDataVisualHeight = md3VisualHeight;
            topDataVisualCenterOffset = 0;
        }
        if (topDataVisualHeight > oY_____1) {
            topDataFont = Gfx.FONT_SMALL;
            topDataVisualHeight = sm2VisualHeight;
        }
        if (topDataVisualHeight > oY_____1) {
            topDataFont = Gfx.FONT_XTINY;
            topDataVisualHeight = xt0VisualHeight;
            topDataVisualCenterOffset = xt0VisualCenterOffset;
        }

        var topDataClearance = topDataVisualHeight * Ui.loadResource(Rez.Strings.topDataClearanceRatio).toFloat();
        if (topDataClearance < 0) {
            topDataClearance = 0;
        }
        var maxTopDataClearance = (oY_____1 - topDataVisualHeight) / 2.0;
        if (maxTopDataClearance < 0) {
            maxTopDataClearance = 0;
        }
        if (topDataClearance > maxTopDataClearance) {
            topDataClearance = maxTopDataClearance;
        }

        var edgeInset = dcWidth * Ui.loadResource(Rez.Strings.horizontalEdgeInset).toFloat();
        var centerGap = topDataClearance;
        var usableWidth = dcWidth - (2 * edgeInset);
        var topDataWidth = usableWidth - (2 * centerGap);
        if (topDataWidth < 0) {
            topDataWidth = 0;
        }
        halfWitt = dcWidth / 2;
        middlew = dcWidth / 3;
        halfMiddleWidth = middlew / 2;
        topCenter = edgeInset + (topDataWidth * (TOP_BEARING_CAPACITY / (TOP_BEARING_CAPACITY + TOP_DISTANCE_CAPACITY))) + centerGap;
        bottomCenter = topCenter;
        slbX1 = edgeInset;
        sldX1 = dcWidth - edgeInset;
        slbX2 = topCenter - centerGap;
        sldX2 = topCenter + centerGap;
        battX = edgeInset;
        todX = dcWidth - edgeInset;
        altX = middlew + halfMiddleWidth;
        tidX = halfWitt / 2;
        distX = 3 * halfWitt / 2;
        paceX = 2 * middlew + halfMiddleWidth;

        var dataVisualBottom = oY_____1 - topDataClearance;
        var dataVisualCenter = dataVisualBottom - (topDataVisualHeight / 2.0);
        oYdat_GF = dataVisualCenter - topDataVisualCenterOffset;
        var labelRegionBottom = dataVisualCenter - (topDataVisualHeight / 2.0);
        oYlbl_GF = labelRegionBottom / 2.0;

        lowerDataFont = Gfx.FONT_LARGE;
        if (!computeLowerLayout(dcHeight, xt0VisualHeight, lg4VisualHeight)) {
            lowerDataFont = Gfx.FONT_MEDIUM;
            if (!computeLowerLayout(dcHeight, xt0VisualHeight, md3VisualHeight)) {
                lowerDataFont = Gfx.FONT_SMALL;
                if (!computeLowerLayout(dcHeight, xt0VisualHeight, sm2VisualHeight)) {
                    tooSmall = true;
                }
            }
        }
    }

    //! Fit and evenly space the lower labels, data rows, and divider lines.
    function computeLowerLayout(dcHeight, labelHeight, dataHeight) {
        var minContent = (3 * labelHeight) + (2 * dataHeight);
        var leftover = (dcHeight - oY_____1) - minContent - (8 * LAYOUT_MIN_GAP);
        if (leftover < 0) {
            return false;
        }
        var gap = LAYOUT_MIN_GAP + (leftover / 8.0);
        var cursor = oY_____1 + gap;
        oYlbl_PHT = cursor + (labelHeight / 2.0);
        cursor += labelHeight + gap;
        oYdat_PHT = cursor + (dataHeight / 2.0);
        cursor += dataHeight + gap;
        oY_____2 = cursor;
        cursor += gap;
        oYdat_TS = cursor + (dataHeight / 2.0);
        cursor += dataHeight + gap;
        oYlbl_TS = cursor + (labelHeight / 2.0);
        cursor += labelHeight + gap;
        oY_____3 = cursor;
        cursor += gap;
        oYdat_BT = cursor + (labelHeight / 2.0);
        return true;
    }

    // //! Record a timer lap and toggle the debug text-box overlays.
    // function onTimerLap() {
    //     core.onTimerLap();
    //     // debugPrintTextboxes = !debugPrintTextboxes;
    //     Ui.requestUpdate(); 
    // }
    // // since the debug print textboxes line is commented out, this
    // // entire function can be commented out, since base class has same

    //! Clear and redraw the complete rectangle data-field display.
    function onUpdate(dc) {
        // -------------------------
        // UNSUPPORTED SMALL LAYOUT
        // -------------------------
        if (tooSmall) {
            dc.setColor(Gfx.COLOR_WHITE, backcol);
            dc.clear();
            dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, (dc.getHeight() - dc.getFontHeight(Gfx.FONT_XTINY)) / 2, Gfx.FONT_XTINY, "layout too small", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        // ---------------------------
        // DEBUG-ADJUSTED Y POSITIONS
        // ---------------------------
        // Indices correspond to debugYOffset and getSelectedDebugY() in display order.
        var yBearingLabel = debugAdjustedY(slbY1, 0);
        var yBearingData = debugAdjustedY(slbY2, 1);
        var yMiddleLabel = debugAdjustedY(oYlbl_PHT, 2);
        var yMiddleData = debugAdjustedY(oYdat_PHT, 3);
        var yTimerDistanceData = debugAdjustedY(oYdat_TS, 4);
        var yTimerDistanceLabel = debugAdjustedY(oYlbl_TS, 5);
        var yBatteryTime = debugAdjustedY(oYdat_BT, 6);

        // --------------------
        // BACKGROUND AND GRID
        // --------------------
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(0, oY_____1, rezWidth, oY_____1);
        dc.drawLine(topCenter, oY_____1, topCenter, 0);
        dc.drawLine(0, oY_____3, rezWidth, oY_____3);
        dc.setPenWidth(1);
        dc.drawLine(0, oY_____2, rezWidth, oY_____2);
        dc.drawLine(middlew, oY_____1, middlew, oY_____2);
        dc.drawLine(2 * middlew, oY_____1, 2 * middlew, oY_____2);
        dc.drawLine(halfWitt, oY_____2, halfWitt, oY_____3);
        dc.drawLine(bottomCenter, oY_____3, bottomCenter, dc.getHeight());
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);

        // ----------
        // TOP FIELDS
        // ----------
        dcdrawText(dc, slbX1, yBearingLabel, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_LEFT);
        if (notMonochrome) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        dcdrawText(dc, slbX2, yBearingData, topDataFont, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, sldX1, yBearingLabel, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_RIGHT);
        dcdrawText(dc, sldX2, yBearingData, topDataFont, getSld(), Gfx.TEXT_JUSTIFY_LEFT);

        // -------------
        // MIDDLE FIELDS
        // -------------
        var midfont = lowerDataFont;
        var hrString = core.heart != null ? core.heart.toString() : "";
        dcdrawText(dc, halfMiddleWidth, yMiddleLabel, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, halfMiddleWidth, yMiddleData, midfont, hrString, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, yMiddleLabel, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, yMiddleData, midfont, getAlt().toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, yMiddleLabel, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, yMiddleData, midfont, getPace(), Gfx.TEXT_JUSTIFY_CENTER);
        // -------------------------
        // TIMER AND DISTANCE FIELDS
        // -------------------------
        dcdrawText(dc, tidX, yTimerDistanceData, midfont, getTid(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, yTimerDistanceLabel, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, yTimerDistanceData, midfont, getDist(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, yTimerDistanceLabel, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER);
        // -------------
        // BOTTOM FIELDS
        // -------------
        dcdrawText(dc, todX, yBatteryTime, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_RIGHT);

        var battery = Sys.getSystemStats().battery.toNumber();
        if (notMonochrome) {
            setBatteryColor(dc, battery);
        }
        dcdrawText(dc, battX, yBatteryTime, Gfx.FONT_XTINY, battery + "%", Gfx.TEXT_JUSTIFY_LEFT);

        // ---------------------------------
        // OPTIONAL LAYOUT DEBUG MID-LINES
        // ---------------------------------
        if (DEBUG_PRINT_MIDLINES) {
            // The selected guide is yellow and heavier; the complete set is green and thin.
            if (DEBUG_PRINT_ONLY_SELECTED_MIDLINE) {
                drawSelectedMidLine(dc, getSelectedDebugY());
            } else {
                drawMidLine(dc, yBearingLabel);
                drawMidLine(dc, yBearingData);
                drawMidLine(dc, yMiddleLabel);
                drawMidLine(dc, yMiddleData);
                drawMidLine(dc, yTimerDistanceData);
                drawMidLine(dc, yTimerDistanceLabel);
                drawMidLine(dc, yBatteryTime);
            }
        }
        
        //Sys.println(memstr()); // checked on instinct2, edge_1000, approachs60 all >40% ok
    }

    //! Apply the optional per-row debug offset to a calculated y-coordinate.
    function debugAdjustedY(y, index) {
        return y + debugYOffset[index];
    }

    //! Return the currently selected debug row's adjusted midpoint.
    function getSelectedDebugY() {
        if (selectedDebugY == 0) {
            return debugAdjustedY(slbY1, 0);
        } else if (selectedDebugY == 1) {
            return debugAdjustedY(slbY2, 1);
        } else if (selectedDebugY == 2) {
            return debugAdjustedY(oYlbl_PHT, 2);
        } else if (selectedDebugY == 3) {
            return debugAdjustedY(oYdat_PHT, 3);
        } else if (selectedDebugY == 4) {
            return debugAdjustedY(oYdat_TS, 4);
        } else if (selectedDebugY == 5) {
            return debugAdjustedY(oYlbl_TS, 5);
        }
        return debugAdjustedY(oYdat_BT, 6);
    }

    //! Draw a horizontal guide through a calculated text midpoint.
    function drawMidLine(dc, y) {
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(0, y, dc.getWidth(), y);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }

    //! Highlight the selected debug midpoint with a heavier guide line.
    function drawSelectedMidLine(dc, y) {
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, y, dc.getWidth(), y);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }

    //! Draw visually centered text and optionally outline its measured glyph box.
    function dcdrawText(dc, x, y, font, text, justification) {
        var yT = y - lg4Mid;
        if (font == Gfx.FONT_XTINY) {
            yT = y - xt0Mid;
        } else if (font == Gfx.FONT_SMALL) {
            yT = y - sm2Mid;
        } else if (font == Gfx.FONT_MEDIUM) {
            yT = y - md3Mid;
        } else if (font == Gfx.FONT_NUMBER_MEDIUM) {
            yT = y - md6Mid;
        }
        dc.drawText(x, yT, font, text, justification);

        // Overlay the drawText anchor and estimated visible glyph bounds for calibration.
        if (debugPrintTextboxes) {
            // Red marks the vertical anchor used by drawText.
            if (notMonochrome) {
                dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
            }
            dc.setPenWidth(3);
            var size = dc.getTextDimensions(text, font);
            var justifiedX = x;
            if (justification == Gfx.TEXT_JUSTIFY_CENTER) {
                justifiedX = x - (size[0] / 2);
            } else if (justification == Gfx.TEXT_JUSTIFY_RIGHT) {
                justifiedX = x - size[0];
            }
            dc.drawLine(x, yT, x, yT + size[1]);
            // Yellow outlines the estimated visible area after justification is applied.
            if (notMonochrome) {
                dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
            }
            dc.setPenWidth(1);

            var ascent = Gfx.getFontAscent(font);
            var accurateHeight = getVisualHeight(font);
            var visualY = yT + ((size[1] - accurateHeight) / 2.0);
            // Number-medium resources provide calibrated trim values for tighter bounds.
            if (font == Gfx.FONT_NUMBER_MEDIUM) {
                var unadjustedTop = yT + (size[1] - ascent.toFloat()) / 2.0;
                accurateHeight = md6VisualHeight;
                visualY = unadjustedTop + md6TrimTop;
            }
            dc.drawRectangle(justifiedX, visualY, size[0], accurateHeight);
            dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        }
        Sys.println(memstr());
    }
}