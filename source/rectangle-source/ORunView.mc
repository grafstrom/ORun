using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ORunView extends ORunViewBase {

    // Unlike the legacy view, which selects hard-coded pixel coordinates for a
    // short list of named devices, this rectangle layout is calculated from the
    // live viewport dimensions and measured visual font heights. It starts with
    // the preferred fonts, falls back through smaller fonts when necessary, and
    // derives the row centers, divider positions, and column anchors from the
    // available space. This lets one implementation support multiple rectangle
    // sizes, provided the calculated content satisfies the fit checks; otherwise
    // the view reports that the assigned layout is too small.

    // TODO: Reduce the activity-distance font size when mileage no longer fits inside its grid cell.
    // TODO: Reduce the top-distance font size when it no longer fits. 
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
    var tooSmall = false; // Whether the viewport cannot fit even the smallest lower-region font.

    var xt0Mid; // Baseline offset that visually centers the extra-tiny font on a Y coordinate.
    var sm2Mid; // Baseline offset that visually centers the small font on a Y coordinate.
    var md3Mid; // Baseline offset that visually centers the medium font on a Y coordinate.
    var lg4Mid; // Baseline offset that visually centers the large font on a Y coordinate.
    var md6Mid; // Baseline offset that visually centers the number-medium font on a Y coordinate.
    var xt0VisualHeight; // Measured visible height of the extra-tiny font.
    var sm2VisualHeight; // Measured visible height of the small font.
    var md3VisualHeight; // Measured visible height of the medium font.
    var lg4VisualHeight; // Measured visible height of the large font.
    var md6VisualHeight; // Visible number-medium height after profile-specific trimming.
    var md6TrimTop; // Profile-specific invisible top padding removed from number-medium text.
    var md6TrimBottom; // Profile-specific invisible bottom padding removed from number-medium text.
    var xt0VisualCenterOffset; // Profile correction from the extra-tiny font-box center to its visual center.
    var md6VisualCenterOffset; // Profile correction from the number-medium font-box center to its visual center.
    var topDataFont = Gfx.FONT_NUMBER_MEDIUM; // Largest font that fits the top data region.
    var lowerDataFont = Gfx.FONT_LARGE; // Largest font that fits the middle and timer-distance regions.

    var rezWidth; // Active viewport width used when drawing horizontal dividers.
    var halfWitt; // Half of the active viewport width.
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

    // Draw measured text bounds and anchor lines when calibrating font placement.
    var debugPrintTextboxes = false; // Whether to draw measured text bounds and anchor lines.
    // Select one of the seven display rows for isolated midpoint debugging.
    var selectedDebugY = 0; // Index of the display row selected for isolated midpoint debugging.
    // Per-row vertical adjustments: top label/data, middle label/data, timer data/label, bottom.
    var debugYOffset = [0, 0, 0, 0, 0, 0, 0]; // Per-row Y corrections used while calibrating text placement.

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

        Y_____1 = 0.30 * dcHeight;
        computeDynamicLayout(dcHeight, dcWidth);
        slbY1 = Ylbl_GF;
        slbY2 = Ydat_GF;
        sldY1 = Ylbl_GF;
        sldY2 = Ydat_GF;
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
        if (topDataVisualHeight > Y_____1) {
            topDataFont = Gfx.FONT_MEDIUM;
            topDataVisualHeight = md3VisualHeight;
            topDataVisualCenterOffset = 0;
        }
        if (topDataVisualHeight > Y_____1) {
            topDataFont = Gfx.FONT_SMALL;
            topDataVisualHeight = sm2VisualHeight;
        }
        if (topDataVisualHeight > Y_____1) {
            topDataFont = Gfx.FONT_XTINY;
            topDataVisualHeight = xt0VisualHeight;
            topDataVisualCenterOffset = xt0VisualCenterOffset;
        }

        var topDataClearance = topDataVisualHeight * Ui.loadResource(Rez.Strings.topDataClearanceRatio).toFloat();
        if (topDataClearance < 0) {
            topDataClearance = 0;
        }
        var maxTopDataClearance = (Y_____1 - topDataVisualHeight) / 2.0;
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

        var dataVisualBottom = Y_____1 - topDataClearance;
        var dataVisualCenter = dataVisualBottom - (topDataVisualHeight / 2.0);
        Ydat_GF = dataVisualCenter - topDataVisualCenterOffset;
        var labelRegionBottom = dataVisualCenter - (topDataVisualHeight / 2.0);
        Ylbl_GF = labelRegionBottom / 2.0;

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
        var leftover = (dcHeight - Y_____1) - minContent - (8 * LAYOUT_MIN_GAP);
        if (leftover < 0) {
            return false;
        }
        var gap = LAYOUT_MIN_GAP + (leftover / 8.0);
        var cursor = Y_____1 + gap;
        Ylbl_PHT = cursor + (labelHeight / 2.0);
        cursor += labelHeight + gap;
        Ydat_PHT = cursor + (dataHeight / 2.0);
        cursor += dataHeight + gap;
        Y_____2 = cursor;
        cursor += gap;
        Ydat_TS = cursor + (dataHeight / 2.0);
        cursor += dataHeight + gap;
        Ylbl_TS = cursor + (labelHeight / 2.0);
        cursor += labelHeight + gap;
        Y_____3 = cursor;
        cursor += gap;
        Ydat_BT = cursor + (labelHeight / 2.0);
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
        var yMiddleLabel = debugAdjustedY(Ylbl_PHT, 2);
        var yMiddleData = debugAdjustedY(Ydat_PHT, 3);
        var yTimerDistanceData = debugAdjustedY(Ydat_TS, 4);
        var yTimerDistanceLabel = debugAdjustedY(Ylbl_TS, 5);
        var yBatteryTime = debugAdjustedY(Ydat_BT, 6);

        // --------------------
        // BACKGROUND AND GRID
        // --------------------
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(0, Y_____1, rezWidth, Y_____1);
        dc.drawLine(topCenter, Y_____1, topCenter, 0);
        dc.drawLine(0, Y_____3, rezWidth, Y_____3);
        dc.setPenWidth(1);
        dc.drawLine(0, Y_____2, rezWidth, Y_____2);
        dc.drawLine(middlew, Y_____1, middlew, Y_____2);
        dc.drawLine(2 * middlew, Y_____1, 2 * middlew, Y_____2);
        dc.drawLine(halfWitt, Y_____2, halfWitt, Y_____3);
        dc.drawLine(bottomCenter, Y_____3, bottomCenter, dc.getHeight());
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
            return debugAdjustedY(Ylbl_PHT, 2);
        } else if (selectedDebugY == 3) {
            return debugAdjustedY(Ydat_PHT, 3);
        } else if (selectedDebugY == 4) {
            return debugAdjustedY(Ydat_TS, 4);
        } else if (selectedDebugY == 5) {
            return debugAdjustedY(Ylbl_TS, 5);
        }
        return debugAdjustedY(Ydat_BT, 6);
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