using Toybox.Math as Math;
using Toybox.Lang as Lang;
using Toybox.System as Sys;

class ORunCore {

    var distConv = 1;
    var unitConv = 1000;
    var heart;
    var speed;
    var dist;
    var tid;
    var startLap = 0;
    var startAlt;
    var startLoca;
    var loca;
    var alt;
    var lap = 1;

    function setDistanceConversion(value) {
        distConv = value;
    }

    function setUnitConversion(value) {
        unitConv = value;
    }

    function compute(info) {
        heart = info.currentHeartRate;
        speed = info.currentSpeed;
        dist = info.elapsedDistance;
        tid = info.elapsedTime;

        if (info.currentLocation != null and lap > startLap) {
            startLoca = info.currentLocation;
            startAlt = info.altitude;
            startLap = lap;
            System.println("  compute: lap is now " + lap);
        }

        if (info.altitude != null and startAlt != null) {
            alt = info.altitude - startAlt;
        }

        loca = info.currentLocation;
    }

    function onTimerStart() {
        lap++;
        System.println("  user pressed Start: lap is now " + lap);
    }

    function onTimerLap() {
        lap++;
        System.println("  user pressed Lap:   lap is now " + lap);
    }

    function getPace(speed) {
        if (speed != null and speed >= 0.5) {
            return fmt_num((unitConv / speed).toNumber());
        }
        return "0.0";
    }

    function fmt_num(num) {
        return (num / 60) + ":" + (num % 60).format("%02d");
    }

    function getDist(dist) {
        if (dist != null) {
            return (dist / unitConv).format("%0.2f");
        }
        return "0.00";
    }

    function getAlt(alt) {
        if (alt != null) {
            return (alt * distConv).toNumber();
        }
        return 0;
    }

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

    function getTod() {
        var klokk = Sys.getClockTime();
        return Lang.format("$1$:$2$:$3$", [klokk.hour.format("%02d"), klokk.min.format("%02d"), klokk.sec.format("%02d")]);
    }

    function degrees(n) {
        return n * (180 / Math.PI);
    }

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
        }
        else if (dLong < -Math.PI) {
            dLong = 2.0 * Math.PI + dLong;
        }

        var calc = atan2(dLong, dPhi);
        var deg = degrees(calc);
        return (deg + 360.0).toNumber() % 360;
    }

    function computeDistance(pos1, pos2) {
        var lat1, lat2, lon1, lon2, lat;
        var dx, dy, distance;

        lat1 = pos1.toDegrees()[0].toFloat();
        lon1 = pos1.toDegrees()[1].toFloat();
        lat2 = pos2.toDegrees()[0].toFloat();
        lon2 = pos2.toDegrees()[1].toFloat();

        lat = (lat1 + lat2) / 2 * 0.01745;
        dx = 111.3 * Math.cos(lat) * (lon1 - lon2);
        dy = 111.3 * (lat1 - lat2);
        distance = 1000 * Math.sqrt(dx * dx + dy * dy);

        return (distConv * distance).toNumber();
    }
}
