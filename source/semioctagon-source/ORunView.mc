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
    var halfWidth;
    var thirdWidth;
    var halfThirdWidth;
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

    const LAYOUT_MIN_GAP = 0.0;
    const TOP_BEARING_CAPACITY = 3.5;
    const TOP_DISTANCE_CAPACITY = 4.0;

    //! Initialize shared view state before configuring the semioctagon layout.
    function initialize() {
        ORunViewBase.initialize();
    }

    //! Measure available fonts and calculate a layout from the live screen dimensions.
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

    //! Estimate visible glyph height while excluding excess font-box padding.
    function getVisualHeight(font) {
        var visualHeight = Gfx.getFontAscent(font).toFloat();
        if (Gfx.getFontDescent(font) != 0) {
            visualHeight = (Gfx.getFontAscent(font).toFloat() + Gfx.getFontDescent(font).toFloat()) * 0.78;
        }
        return visualHeight;
    }

    //! Select fonts and derive field positions from the available screen dimensions.
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
        halfWidth = dcWidth / 2;
        thirdWidth = dcWidth / 3;
        halfThirdWidth = thirdWidth / 2;
        topCenter = edgeInset + (topDataWidth * (TOP_BEARING_CAPACITY / (TOP_BEARING_CAPACITY + TOP_DISTANCE_CAPACITY))) + centerGap;
        bottomCenter = topCenter;
        slbX1 = edgeInset;
        sldX1 = dcWidth - edgeInset;
        slbX2 = topCenter - centerGap;
        sldX2 = topCenter + centerGap;
        battX = edgeInset;
        todX = dcWidth - edgeInset;
        altX = thirdWidth + halfThirdWidth;
        tidX = halfWidth / 2;
        distX = 3 * halfWidth / 2;
        paceX = 2 * thirdWidth + halfThirdWidth;

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

    //! Clear and redraw the complete semioctagon data-field display.
    function onUpdate(dc) {
        if (tooSmall) {
            dc.setColor(Gfx.COLOR_WHITE, backcol);
            dc.clear();
            dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, (dc.getHeight() - dc.getFontHeight(Gfx.FONT_XTINY)) / 2, Gfx.FONT_XTINY, "layout too small", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(0, oY_____1, rezWidth, oY_____1);
        dc.drawLine(topCenter, oY_____1, topCenter, 0);
        dc.drawLine(0, oY_____3, rezWidth, oY_____3);
        dc.setPenWidth(1);
        dc.drawLine(0, oY_____2, rezWidth, oY_____2);
        dc.drawLine(thirdWidth, oY_____1, thirdWidth, oY_____2);
        dc.drawLine(2 * thirdWidth, oY_____1, 2 * thirdWidth, oY_____2);
        dc.drawLine(halfWidth, oY_____2, halfWidth, oY_____3);
        dc.drawLine(bottomCenter, oY_____3, bottomCenter, dc.getHeight());
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);

        dcdrawText(dc, slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_RIGHT);
        if (notMonochrome) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        dcdrawText(dc, slbX2, slbY2, topDataFont, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_LEFT);
        dcdrawText(dc, sldX2, sldY2, topDataFont, getSld(), Gfx.TEXT_JUSTIFY_LEFT);

        var middleFont = lowerDataFont;
        var heartString = core.heart != null ? core.heart.toString() : "";
        dcdrawText(dc, halfThirdWidth, oYlbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, halfThirdWidth, oYdat_PHT, middleFont, heartString, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, oYlbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, oYdat_PHT, middleFont, getAlt().toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, oYlbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, oYdat_PHT, middleFont, getPace(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, oYdat_TS, middleFont, getTid(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, oYlbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, oYdat_TS, middleFont, getDist(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, oYlbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, todX, oYdat_BT, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT);

        var battery = Sys.getSystemStats().battery.toNumber();
        if (notMonochrome) {
            setBatteryColor(dc, battery);
        }
        dcdrawText(dc, battX, oYdat_BT, Gfx.FONT_XTINY, battery + "%", Gfx.TEXT_JUSTIFY_RIGHT);
    }

    //! Draw text with its visual midpoint aligned to the supplied y-coordinate.
    function dcdrawText(dc, x, y, font, text, justification) {
        var textY = y - lg4Mid;
        if (font == Gfx.FONT_XTINY) {
            textY = y - xt0Mid;
        } else if (font == Gfx.FONT_SMALL) {
            textY = y - sm2Mid;
        } else if (font == Gfx.FONT_MEDIUM) {
            textY = y - md3Mid;
        } else if (font == Gfx.FONT_NUMBER_MEDIUM) {
            textY = y - md6Mid;
        }
        dc.drawText(x, textY, font, text, justification);
    }
}