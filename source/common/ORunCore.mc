using Toybox.Math as Math;
using Toybox.Lang as Lang;
using Toybox.System as Sys;

class ORunCore {

    // Unit conversion factors configured by the shared view during initialization.
    var distConv = 1;
    var unitConv = 1000;
    // Latest activity values supplied to compute().
    var heart;
    var speed;
    var dist;
    var tid;
    // Lap-relative position and altitude state used for bearing, distance, and ascent.
    var startLap = 0;
    var startAlt;
    var startLoca;
    var loca;
    var alt;
    var lap = 1;

    //! Configure the meters-to-display-units conversion used for short distances and altitude.
    function setDistanceConversion(value) {
        distConv = value;
    }

    //! Configure the meters-per-display-unit conversion used for pace and elapsed distance.
    function setUnitConversion(value) {
        unitConv = value;
    }

    //! Capture the latest activity sample and establish lap-relative location and altitude origins.
    function compute(info) {
        heart = info.currentHeartRate;
        speed = info.currentSpeed;
        dist = info.elapsedDistance;
        tid = info.elapsedTime;

        if (info.currentLocation != null and lap > startLap) {
            startLoca = info.currentLocation;
            startAlt = info.altitude;
            startLap = lap;
        }

        if (info.altitude != null and startAlt != null) {
            alt = info.altitude - startAlt;
        }

        loca = info.currentLocation;
    }

    //! Advance the logical lap when activity timing starts.
    function onTimerStart() {
        lap++;
    }

    //! Advance the logical lap when the user records a lap.
    function onTimerLap() {
        lap++;
    }

    //! Convert speed to a formatted pace in the configured distance units.
    function getPace(speed) {
        if (speed != null and speed >= 0.5) {
            return fmt_num((unitConv / speed).toNumber());
        }
        return "0.0";
    }

    //! Format a duration in seconds as minutes and zero-padded seconds.
    function fmt_num(num) {
        return (num / 60) + ":" + (num % 60).format("%02d");
    }

    //! Format elapsed distance in the configured long-distance units.
    function getDist(dist) {
        if (dist != null) {
            return (dist / unitConv).format("%0.2f");
        }
        return "0.00";
    }

    //! Convert lap-relative altitude to the configured short-distance units.
    function getAlt(alt) {
        if (alt != null) {
            return (alt * distConv).toNumber();
        }
        return 0;
    }

    //! Format elapsed milliseconds as MM:SS or H:MM:SS.
    function getTid(tid) {
        if (tid != null) {
            var totsec = tid / 1000;
            var sec = totsec % 60;
            var totmin = totsec / 60;
            var min = totmin % 60;
            var hour = totmin / 60;

            if (hour > 0) {
                return Lang.format("$1$:$2$:$3$", [hour, min.format("%02d"), sec.format("%02d")]);
            }
            return Lang.format("$1$:$2$", [min.format("%02d"), sec.format("%02d")]);
        }
        return "00:00";
    }

    //! Return the current local clock time as HH:MM:SS.
    function getTod() {
        var klokk = Sys.getClockTime();
        return Lang.format("$1$:$2$:$3$", [klokk.hour.format("%02d"), klokk.min.format("%02d"), klokk.sec.format("%02d")]);
    }

    //! Convert an angle from radians to degrees.
    function degrees(n) {
        return n * (180 / Math.PI);
    }

    //! Calculate an angle by quadrant when a native two-argument arctangent is unavailable.
    function atan2(y, x) {
        if (x > 0) {
            return Math.atan(y / x);
        }
        if (x < 0) {
            if (y >= 0) {
                return Math.atan(y / x) + Math.PI;
            }
            return Math.atan(y / x) - Math.PI;
        }
        if (y > 0) {
            return Math.PI / 2;
        }
        if (y < 0) {
            return -Math.PI / 2;
        }
        return 0.0;
    }

    //! Calculate the rhumb-line bearing in degrees from one position to another.
    function computeBearing(pos1, pos2) {
        var startLat = pos1.toRadians()[0].toFloat();
        var startLong = pos1.toRadians()[1].toFloat();
        var endLat = pos2.toRadians()[0].toFloat();
        var endLong = pos2.toRadians()[1].toFloat();
        var dLong = endLong - startLong;
        var dPhi = Math.log(Math.tan(endLat / 2.0 + Math.PI / 4.0) /
                             Math.tan(startLat / 2.0 + Math.PI / 4.0), 10);

        if (dLong > Math.PI) {
            dLong = -(2.0 * Math.PI - dLong);
        } else if (dLong < -Math.PI) {
            dLong = 2.0 * Math.PI + dLong;
        }

        var calc = atan2(dLong, dPhi);
        var deg = degrees(calc);
        return (deg + 360.0).toNumber() % 360;
    }

    //! Approximate the distance between two positions and convert it to display units.
    function computeDistance(pos1, pos2) {
        var lat1 = pos1.toDegrees()[0].toFloat();
        var lon1 = pos1.toDegrees()[1].toFloat();
        var lat2 = pos2.toDegrees()[0].toFloat();
        var lon2 = pos2.toDegrees()[1].toFloat();
        var lat = (lat1 + lat2) / 2 * 0.01745;
        var dx = 111.3 * Math.cos(lat) * (lon1 - lon2);
        var dy = 111.3 * (lat1 - lat2);
        var distance = 1000 * Math.sqrt(dx * dx + dy * dy);
        return (distConv * distance).toNumber();
    }
}