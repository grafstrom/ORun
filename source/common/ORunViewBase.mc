using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ORunViewBase extends Ui.DataField {

    var backcol;
    var forecol;
    var linecol;
    var notMonochrome;

    var distLabel;
    var paceLabel;
    var slbLabel;
    var sldLabel;
    var tmrLabel;
    var hbtLabel;
    var altLabel;

    var distConv;
    var unitConv;
    var core;

    //! Initialize shared colors, labels, unit conversions, and activity data handling.
    function initialize() {
        DataField.initialize();
        core = new ORunCore();

        backcol = Gfx.COLOR_BLACK;
        forecol = Gfx.COLOR_WHITE;
        linecol = Gfx.COLOR_BLUE;
        notMonochrome = Ui.loadResource(Rez.Strings.notMonochrome).equals("1");

        slbLabel = Ui.loadResource(Rez.Strings.slb);
        tmrLabel = Ui.loadResource(Rez.Strings.timer);
        paceLabel = Ui.loadResource(Rez.Strings.pace);
        distLabel = Ui.loadResource(Rez.Strings.dist);
        hbtLabel = Ui.loadResource(Rez.Strings.hbt);
        altLabel = Ui.loadResource(Rez.Strings.alt);

        if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) {
            sldLabel = Ui.loadResource(Rez.Strings.sld_ft);
            unitConv = 1609;
            distConv = 3.28084;
        } else {
            sldLabel = Ui.loadResource(Rez.Strings.sld_m);
            unitConv = 1000;
            distConv = 1;
        }
        core.setDistanceConversion(distConv);
        core.setUnitConversion(unitConv);
    }

    //! Forward each activity sample to the shared calculation core.
    function compute(info) {
        core.compute(info);
    }

    //! Start a new logical lap and request an immediate display refresh.
    function onTimerStart() {
        core.onTimerStart();
        Ui.requestUpdate();
    }

    //! Record a timer lap and request an immediate display refresh.
    function onTimerLap() {
        core.onTimerLap();
        Ui.requestUpdate();
        notMonochrome = !notMonochrome;
    }

    //! Format the current speed as the configured pace value.
    function getPace() {
        return core.getPace(core.speed);
    }

    //! Format the elapsed distance using the configured distance units.
    function getDist() {
        return core.getDist(core.dist);
    }

    //! Return altitude gained since the current lap began.
    function getAlt() {
        return core.getAlt(core.alt);
    }

    //! Format elapsed activity time for display.
    function getTid() {
        return core.getTid(core.tid);
    }

    //! Format the current clock time for display.
    function getTod() {
        return core.getTod();
    }

    //! Calculate the bearing from the lap start when both locations are available.
    function getBearing() {
        if (core.startLoca != null and core.loca != null) {
            return core.computeBearing(core.startLoca, core.loca).toString();
        }
        return "";
    }

    //! Calculate straight-line distance from the lap start when locations are available.
    function getSld() {
        if (core.startLoca != null and core.loca != null) {
            return core.computeDistance(core.startLoca, core.loca).toString();
        }
        return "";
    }

    //! Select the battery text color from the remaining charge thresholds.
    function setBatteryColor(dc, battery) {
        if (battery > 30) {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        } else if (battery > 10) {
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }
    }

    //! Return the percentage of system memory currently available.
    function memstr() {
        return ((Sys.getSystemStats().freeMemory.toFloat() / Sys.getSystemStats().totalMemory.toFloat()) * 100).toNumber() + "% available";
        //! I tested memory usage by pasting the following line at the end of onUpdate
        //! checked on instinct2, edge_1000, approachs60 all >40%, so all ok.
        //Sys.println(memstr()); 
    } 
}