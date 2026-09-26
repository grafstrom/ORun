using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ORunView extends ORunViewBase {

    // Unlike the legacy view, which selects hard-coded pixel coordinates for a
    // short list of named devices, this semioctagon layout scales shared width
    // and height ratios to a matching full-screen device profile. Unsupported
    // viewport dimensions are rejected instead of being given a partial layout.
    // The clipped upper-right edge also requires value-dependent handling: the
    // straight-line-distance value switches from NUMBER_MEDIUM to MEDIUM at the
    // device resource threshold, and selected digit ranges shift its X anchor
    // left so the value remains inside the available top region.

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
    var changeLayout = false; // Whether the assigned viewport differs from the supported full-screen profile.
    var compactSldThreshold = 0; // Distance at which the top-right value switches to a more compact layout.

    var xt0Mid; // Baseline offset that visually centers the extra-tiny font on a Y coordinate.
    var md3Mid; // Baseline offset that visually centers the medium font on a Y coordinate.
    var md6Mid; // Baseline offset that visually centers the number-medium font on a Y coordinate.
    var md6VisualHeight; // Visible number-medium height after profile-specific trimming.
    var md6VisualCenterOffset; // Profile correction from the number-medium font-box center to its visual center.

    var rezWidth; // Active viewport width used when drawing horizontal dividers.
    var halfWidth; // Half of the active viewport width.
    var thirdWidth; // Width of one column in the three-column middle region.
    var halfThirdWidth; // Horizontal center of the first middle-region column.
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

    // Top-region geometry is width/height proportional; profile resources can
    // reduce both data gaps without changing the shared centerline or labels.
    const TOP_DIVIDER_HEIGHT_RATIO = 0.43;
    const TOP_CENTER_RATIO = 0.30;
    const TOP_DATA_HORIZONTAL_GAP_RATIO = 0.042273;
    const TOP_DATA_HORIZONTAL_ADJUSTMENT_RATIO = 0.01;
    const TOP_DATA_VERTICAL_GAP_RATIO = 0.042273;
    const TOP_LABEL_GAP_RATIO = 0.042273;
    const TOP_LABEL_DOWN_SHIFT_RATIO = 0.03;
    // Four-digit SLD values need extra room against the clipped upper-right edge.
    const FOUR_DIGIT_SLD_LEFT_SHIFT_RATIO = 0.02;

    // Lower-region ratios define label/data centers and divider lines directly.
    // Keeping them independent makes each horizontal band tunable in isolation.
    const LOWER_LABEL_PHT_RATIO = 0.484077;
    const LOWER_DATA_PHT_RATIO = 0.597983;
    const LOWER_DIVIDER_RATIO = 0.660923;
    const LOWER_DATA_TS_RATIO = 0.723864;
    const LOWER_LABEL_TS_RATIO = 0.831770;
    const BOTTOM_DIVIDER_RATIO = 0.891847;
    const BOTTOM_DATA_RATIO = 0.945923;

    // Bottom battery/time anchors face inward around a dedicated vertical split.
    const BOTTOM_CENTER_RATIO = 0.399818;
    const BOTTOM_TEXT_GAP_RATIO = 0.03;

    //! Initialize shared view state before configuring the semioctagon layout.
    function initialize() {
        ORunViewBase.initialize();
    }

    //! Measure the three fixed fonts and scale the semioctagon layout to the live dimensions.
    function onLayout(dc) {
        var dcHeight = dc.getHeight();
        var dcWidth = dc.getWidth();
        rezWidth = dcWidth;

        // comment out the below two lines when completed debugging, or otherwise risk extra
        // memory usage because onLayout is called every sec on semi-octagonal devices
        // var device = Ui.loadResource(Rez.Strings.device);
        // Sys.println("device: " + device + "   dcHeight is " + dcHeight + "   dcWidth is " + dcWidth);

        // This layout is calibrated only for the full profile dimensions. Garmin
        // can assign smaller multi-field viewports, which must not reuse this grid.
        var expectedWidth = Ui.loadResource(Rez.Strings.width).toNumber();
        var expectedHeight = Ui.loadResource(Rez.Strings.height).toNumber();
        compactSldThreshold = Ui.loadResource(Rez.Strings.compactSldThreshold).toNumber();
        changeLayout = dcWidth != expectedWidth or dcHeight != expectedHeight;
        if (changeLayout) {
            return;
        }

        var xt0Acc = getVisualHeight(Gfx.FONT_XTINY);
        var md3Acc = getVisualHeight(Gfx.FONT_MEDIUM);
        var md6Acc = getVisualHeight(Gfx.FONT_NUMBER_MEDIUM);

        var xt0TopPadding = (dc.getFontHeight(Gfx.FONT_XTINY).toFloat() - xt0Acc) / 2.0;
        var md3TopPadding = (dc.getFontHeight(Gfx.FONT_MEDIUM).toFloat() - md3Acc) / 2.0;
        var md6TopPadding = (dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM).toFloat() - md6Acc) / 2.0;

        // Convert Garmin font boxes into visual midpoint offsets. Resource shifts
        // remain available because font padding varies subtly between profiles.
        var xt0MidShift = Ui.loadResource(Rez.Strings.xt0MidShift).toFloat();
        xt0Mid = xt0TopPadding + (xt0Acc / 2.0) + xt0MidShift;
        md3Mid = md3TopPadding + (md3Acc / 2.0);
        var md6MidShift = Ui.loadResource(Rez.Strings.md6MidShift).toFloat();
        md6Mid = md6TopPadding + (md6Acc / 2.0) + md6MidShift;
        var md6TrimTop = Ui.loadResource(Rez.Strings.md6PadTop).toFloat();
        var md6TrimBottom = Ui.loadResource(Rez.Strings.md6PadBot).toFloat();
        md6VisualHeight = Gfx.getFontAscent(Gfx.FONT_NUMBER_MEDIUM).toFloat() - md6TrimTop - md6TrimBottom;
        if (md6VisualHeight < 0) {
            md6VisualHeight = 0;
        }
        md6VisualCenterOffset = ((md6TrimTop - md6TrimBottom) / 2.0) - md6MidShift;

        // The upper divider owns the top region; all remaining anchors are derived
        // from the same live dimensions after the profile-size check succeeds.
        Y_____1 = TOP_DIVIDER_HEIGHT_RATIO * dcHeight;
        computeLayout(dcHeight, dcWidth);

        // Preserve the common label/data coordinate names used by other shapes.
        slbY1 = Ylbl_GF;
        slbY2 = Ydat_GF;
        sldY1 = Ylbl_GF;
        sldY2 = Ydat_GF;
    }

    //! Estimate visible glyph height while excluding excess font-box padding.
    function getVisualHeight(font) {
        var visualHeight = Gfx.getFontAscent(font).toFloat();
        if (Gfx.getFontDescent(font) != 0) {
            visualHeight = (Gfx.getFontAscent(font).toFloat() + Gfx.getFontDescent(font).toFloat()) * 0.78;
        }
        return visualHeight;
    }

    //! Derive all semioctagon anchors directly from fixed width and height ratios.
    function computeLayout(dcHeight, dcWidth) {
        // Shared column centers divide the middle region into thirds and halves.
        halfWidth = dcWidth / 2;
        thirdWidth = dcWidth / 3;
        halfThirdWidth = thirdWidth / 2;

        // Top and bottom vertical dividers are intentionally independent.
        bottomCenter = dcWidth * BOTTOM_CENTER_RATIO;
        topCenter = dcWidth * TOP_CENTER_RATIO;

        // Profiles tune vertical divider spacing where clipped edges require it.
        // Horizontal centerline spacing is shared by every semioctagon profile.
        var topLabelGap = dcWidth * TOP_LABEL_GAP_RATIO;
        var topDataVerticalAdjustment = Ui.loadResource(Rez.Strings.topDataVerticalAdjustmentRatio).toFloat();
        var topDataHorizontalGap = dcWidth * (TOP_DATA_HORIZONTAL_GAP_RATIO - TOP_DATA_HORIZONTAL_ADJUSTMENT_RATIO);

        // Labels and values have separate centerline gaps so they can be tuned
        // without coupling text widths or justification behavior.
        slbX1 = topCenter - topLabelGap;
        sldX1 = topCenter + topLabelGap;
        slbX2 = topCenter - topDataHorizontalGap;
        sldX2 = topCenter + topDataHorizontalGap;
        battX = bottomCenter - (dcWidth * BOTTOM_TEXT_GAP_RATIO);
        todX = bottomCenter + (dcWidth * BOTTOM_TEXT_GAP_RATIO);
        altX = thirdWidth + halfThirdWidth;
        tidX = halfWidth / 2;
        distX = 3 * halfWidth / 2;
        paceX = 2 * thirdWidth + halfThirdWidth;

        // Anchor the visible bottom of both top values above the divider, then
        // compensate for asymmetric NUMBER_MEDIUM padding around its glyphs.
        var topDataVerticalGap = dcHeight * (TOP_DATA_VERTICAL_GAP_RATIO - topDataVerticalAdjustment);
        var dataVisualCenter = Y_____1 - topDataVerticalGap - (md6VisualHeight / 2.0);
        Ydat_GF = dataVisualCenter - md6VisualCenterOffset;

        // Center both tiny labels in the remaining upper space, with a deliberate
        // downward correction that keeps them visually associated with their data.
        var labelRegionBottom = dataVisualCenter - (md6VisualHeight / 2.0);
        Ylbl_GF = (labelRegionBottom / 2.0) + (dcHeight * TOP_LABEL_DOWN_SHIFT_RATIO);

        // Fixed height ratios replace font-fit retries; every supported profile
        // uses FONT_MEDIUM data and the same proportional band structure.
        Ylbl_PHT = dcHeight * LOWER_LABEL_PHT_RATIO;
        Ydat_PHT = dcHeight * LOWER_DATA_PHT_RATIO;
        Y_____2 = dcHeight * LOWER_DIVIDER_RATIO;
        Ydat_TS = dcHeight * LOWER_DATA_TS_RATIO;
        Ylbl_TS = dcHeight * LOWER_LABEL_TS_RATIO;
        Y_____3 = dcHeight * BOTTOM_DIVIDER_RATIO;
        Ydat_BT = dcHeight * BOTTOM_DATA_RATIO;
    }

    //! Clear and redraw the complete semioctagon data-field display.
    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, backcol);
        dc.clear();
        if (changeLayout) {
            // Render no partial data when Garmin assigns an unsupported viewport.
            dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, (dc.getHeight() - dc.getFontHeight(Gfx.FONT_XTINY)) / 2,
                Gfx.FONT_XTINY, "change layout", Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        // Thick lines bound the major top and bottom regions.
        dc.setColor(linecol, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(0, Y_____1, rezWidth, Y_____1);
        dc.drawLine(0, Y_____3, rezWidth, Y_____3);

        // Thin lines subdivide the five middle data fields.
        dc.setPenWidth(1);
        dc.drawLine(topCenter, Y_____1, topCenter, 0); // top center line make thin here

        dc.drawLine(0, Y_____2, rezWidth, Y_____2);
        dc.drawLine(thirdWidth, Y_____1, thirdWidth, Y_____2);
        dc.drawLine(2 * thirdWidth, Y_____1, 2 * thirdWidth, Y_____2);
        dc.drawLine(halfWidth, Y_____2, halfWidth, Y_____3);
        dc.drawLine(bottomCenter, Y_____3, bottomCenter, dc.getHeight());
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);

        dcdrawText(dc, slbX1, slbY1, Gfx.FONT_XTINY, slbLabel, Gfx.TEXT_JUSTIFY_RIGHT);
        if (notMonochrome) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
        dcdrawText(dc, slbX2, slbY2, Gfx.FONT_NUMBER_MEDIUM, getBearing(), Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(forecol, Gfx.COLOR_TRANSPARENT);
        dcdrawText(dc, sldX1, sldY1, Gfx.FONT_XTINY, sldLabel, Gfx.TEXT_JUSTIFY_LEFT);
        var sldString = "";
        var sldDataX = sldX2;
        var sldDataFont = Gfx.FONT_NUMBER_MEDIUM;
        if (core.startLoca != null and core.loca != null) {
            var sldDistance = core.computeDistance(core.startLoca, core.loca);
            sldString = sldDistance.toString();
            // A zero threshold disables compaction; device resources select the
            // first distance that uses the already-measured medium font.
            if (compactSldThreshold > 0 and sldDistance >= compactSldThreshold) {
                sldDataFont = Gfx.FONT_MEDIUM;
            }
            // Preserve the existing horizontal corrections for constrained ranges.
            if (sldDistance >= 100 and sldDistance < 200) {
                sldDataX -= rezWidth * FOUR_DIGIT_SLD_LEFT_SHIFT_RATIO;
            }
            if (sldDistance >= 1000 and sldDistance < 2000) {
                sldDataX -= rezWidth * FOUR_DIGIT_SLD_LEFT_SHIFT_RATIO;
            }
            if (sldDistance >= 10000 and sldDistance < 20000) {
                sldDataX -= rezWidth * FOUR_DIGIT_SLD_LEFT_SHIFT_RATIO;
            }
        }
        dcdrawText(dc, sldDataX, sldY2, sldDataFont, sldString, Gfx.TEXT_JUSTIFY_LEFT);

        var heartString = core.heart != null ? core.heart.toString() : "";
        dcdrawText(dc, halfThirdWidth, Ylbl_PHT, Gfx.FONT_XTINY, hbtLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, halfThirdWidth, Ydat_PHT, Gfx.FONT_MEDIUM, heartString, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, Ylbl_PHT, Gfx.FONT_XTINY, altLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, altX, Ydat_PHT, Gfx.FONT_MEDIUM, getAlt().toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, Ylbl_PHT, Gfx.FONT_XTINY, paceLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, paceX, Ydat_PHT, Gfx.FONT_MEDIUM, getPace(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, Ydat_TS, Gfx.FONT_MEDIUM, getTid(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, tidX, Ylbl_TS, Gfx.FONT_XTINY, tmrLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, Ydat_TS, Gfx.FONT_MEDIUM, getDist(), Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, distX, Ylbl_TS, Gfx.FONT_XTINY, distLabel, Gfx.TEXT_JUSTIFY_CENTER);
        dcdrawText(dc, todX, Ydat_BT, Gfx.FONT_XTINY, getTod(), Gfx.TEXT_JUSTIFY_LEFT);

        var battery = Sys.getSystemStats().battery.toNumber();
        if (notMonochrome) {
            setBatteryColor(dc, battery);
        }
        dcdrawText(dc, battX, Ydat_BT, Gfx.FONT_XTINY, battery + "%", Gfx.TEXT_JUSTIFY_RIGHT);
    }

    //! Draw text with the visible glyph midpoint aligned to the supplied anchor.
    function dcdrawText(dc, x, y, font, text, justification) {
        // Each stored Y coordinate represents a visual center, not Garmin's
        // font-box top edge, so subtract the measured midpoint before drawing.
        var textY = y;
        if (font == Gfx.FONT_XTINY) {
            textY = y - xt0Mid;
        } else if (font == Gfx.FONT_MEDIUM) {
            textY = y - md3Mid;
        } else if (font == Gfx.FONT_NUMBER_MEDIUM) {
            textY = y - md6Mid;
        }
        dc.drawText(x, textY, font, text, justification);
    }
}