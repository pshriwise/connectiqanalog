//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as Am;
using Toybox.WatchUi as Ui;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends Ui.WatchFace
{
    var font;
    var isAwake;
    var screenShape;
    var dndIcon;

    function initialize() {
        WatchFace.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
    }

    function onLayout(dc) {
        font = Ui.loadResource(Rez.Fonts.id_font_black_diamond);
        if (Sys.getDeviceSettings() has :doNotDisturb) {
            dndIcon = Ui.loadResource(Rez.Drawables.DoNotDisturbIcon);
        } else {
            dndIcon = null;
        }
    }

 
	// Draw a watch hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	// @param coords Polygon coordinates of the hand
	function drawHand(dc, angle, coords){
		var result = new [coords.size()];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos = Math.cos(angle + Math.PI);
        var sin = Math.sin(angle + Math.PI);

        // Transform the coordinates
        for (var i = 0; i < coords.size(); i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [centerX + x, centerY + y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
        dc.fillPolygon(result);
	}
			
	// Draw the hour hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	function drawHourHand(dc, angle) {	
		// Define hand shape using coordinates
		var length = 65;
		var width = 3.5;
		// Define shape of the hand
		// Outer pointer
		var coords_outer = [[-width ,0],[width ,0],[width ,(length - 5)],[0,length],[-width ,(length-5)]];
		// Inner accent
		var coords_inner = [[-(width - 2),5],[(width - 2),5],[(width - 2),(length - 11)],[-(width - 2),(length - 11)]];

		// Draw these with their color and orientation
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
		drawHand(dc, angle, coords_outer);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		drawHand(dc, angle, coords_inner);
	}

	// Draw the minute hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	function drawMinuteHand(dc, angle) {
	
		// Define hand shape using coordinates
		var length = 95;
		var width = 3.5;
		// Define shape of the hand
		// Outer pointer
		var coords_outer = [[-width ,0],[width ,0],[width ,(length - 5)],[0,length],[-width ,(length-5)]];
		// Inner accent
		var coords_inner = [[-(width - 2),5],[(width - 2),5],[(width - 2),(length - 11)],[-(width - 2),(length - 11)]];

		// Draw hands with their color and orientation
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
		drawHand(dc, angle, coords_outer);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		drawHand(dc, angle, coords_inner);
	}
	
	// Draw the second hand on the watch
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	function drawSecondHand(dc, angle) {
		// Define hand shape using coordinates
		var length = 85;
		var width = 3;
		// Define hand shape
		var coords = [[0,-(length * 0.3)],[width,0],[0,length],[-width,0]];
		// Draw the hand with it's appropriate color
		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		drawHand(dc, angle, coords);
	}
	
	function drawNotificationCount(dc) {
		var numNotes = Sys.getDeviceSettings().notificationCount;
		if (0 < numNotes) {
			var notifyimage = Rez.Drawables.id_notificationicon;
			var bitmap = Ui.loadResource(notifyimage);			
			var width = dc.getWidth(); 
			var height = dc.getHeight(); 
			var xcenter = (width / 2);
			var ycenter = 42; 
			var noteStr = Lang.format("$1$", [numNotes]);
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);						
			dc.drawBitmap(xcenter-13, ycenter+2, bitmap);			
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);			
			dc.drawText(xcenter, ycenter, Gfx.FONT_TINY, noteStr, Gfx.TEXT_JUSTIFY_CENTER);
		}
	}
	
	function drawAlarm(dc) {
		if ( 0 < Sys.getDeviceSettings().alarmCount) {
			// load bitmap of alarm icon
			var alarmimage = Rez.Drawables.id_alarmicon;
			var bitmap = Ui.loadResource(alarmimage);
			var xcenter = (dc.getWidth() / 2) + 27;
			var ycenter = 40; 
			dc.drawBitmap(xcenter, ycenter, bitmap);
		}
	}
	function drawBluetooth(dc) {
		// only draw if device is connected
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		if(Sys.getDeviceSettings().phoneConnected) {
			// Context reference values
			var width = dc.getWidth();
			var height = dc.getHeight();
			// Symbol parameters
			var xcenter = (width / 2) - 35;
			var ycenter = 55; 
			var xoffset = 5;
			var symbolHeight = 20;
			dc.setPenWidth(1.8);
			// Draw the symbol
			dc.drawLine(xcenter, ycenter - (symbolHeight/2),xcenter,ycenter+(symbolHeight/2));
			dc.drawLine(xcenter, ycenter - (symbolHeight/2),xcenter+xoffset,ycenter - (symbolHeight/4));
			dc.drawLine(xcenter+xoffset,ycenter - (symbolHeight/4),xcenter-xoffset,ycenter + (symbolHeight/4));
			dc.drawLine(xcenter, ycenter + (symbolHeight/2),xcenter+xoffset,ycenter + (symbolHeight/4));
			dc.drawLine(xcenter+xoffset,ycenter + (symbolHeight/4),xcenter-xoffset,ycenter - (symbolHeight/4));
		}
	}
	
	// Draw an arc on the left side from 7-11 representing
	// a step meter to goal
	// @param dc Device Context used to draw
	function drawMoveArc(dc) {
		var startRad = -2  * Math.PI / 6; // start at 7
		var endRad = 2 * Math.PI / 6; // end at 11
		var radius = dc.getWidth();
		var toDeg = 180 / Math.PI;
		var moveFrac = Am.getInfo().moveBarLevel.toFloat() / Am.MOVE_BAR_LEVEL_MAX.toFloat();
		moveFrac = moveFrac.abs();
		if (moveFrac <= 0.01 ) { moveFrac = 0.01; }
		if (moveFrac > 1 ) { moveFrac = 1; }
		endRad = startRad + (endRad-startRad)*moveFrac;

		if ( 1 == moveFrac )  { dc.setColor(Gfx.COLOR_RED,Gfx.COLOR_TRANSPARENT); }
		else { dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT); }

		dc.setPenWidth(5);
		dc.drawArc(dc.getWidth()/2,dc.getHeight()/2,105,dc.ARC_COUNTER_CLOCKWISE,startRad*toDeg,endRad*toDeg);
		
	}
	// Draw an arc on the left side from 7-11 representing
	// a step meter to goal
	// @param dc Device Context used to draw
	function drawStepArc(dc) {
		var startRad = 8  * Math.PI / 6; // start at 7
		var endRad = 4 * Math.PI / 6; // end at 11
		var radius = dc.getWidth();
		var toDeg = 180 / Math.PI;
		var stepFrac = Am.getInfo().steps.toFloat()/Am.getInfo().stepGoal.toFloat();
		stepFrac = stepFrac.abs();
		if (stepFrac <= 0.01 ) { stepFrac = 0.01; }
		if (stepFrac > 1 ) { stepFrac = 1; }
		endRad = startRad + (endRad-startRad)*stepFrac;

		if ( 1 == stepFrac )  { dc.setColor(Gfx.COLOR_GREEN,Gfx.COLOR_TRANSPARENT); }
		else { dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT); }

		dc.setPenWidth(5);
		dc.drawArc(dc.getWidth()/2,dc.getHeight()/2,105,dc.ARC_CLOCKWISE,startRad*toDeg,endRad*toDeg);
		
	}
    // Draw the hash mark symbols on the watch
    // @param dc Device context
    function drawHashMarks(dc) {
    
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Draw hashmarks differently depending on screen geometry
        if (Sys.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = width / 2;
            var innerRad = outerRad - 10;
            // Loop through each minute and draw tick marks
            for (var i = 0; i <= 59; i += 1) {
            	var angle = i * Math.PI / 30;
            	
            	// thicker lines at 5 min intervals
            	if( (i % 5) == 0) {
                    dc.setPenWidth(3);             
                }
                else {
                    dc.setPenWidth(1);            
                }
                // longer lines at intermediate 5 min marks
                if( (i % 5) == 0 && !((i % 15) == 0)) {               		
            		sY = (innerRad-10) * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = (innerRad-10) * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
                }
                else {
                	sY = innerRad * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = innerRad * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
            	}
                sX += outerRad; sY += outerRad;
                eX += outerRad; eY += outerRad;
                dc.drawLine(sX, sY, eX, eY);
            }
        } else {
            var coords = [0, width / 4, (3 * width) / 4, width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((width / 2.0) - coords[i]) / (height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks
                dc.fillPolygon([[coords[i] - 1, height-2], [upperX - 1, height - 12], [upperX + 1, height - 12], [coords[i] + 1, height - 2]]);
            }
        }
    }
	// Draw the battery percentage
    // @param dc Device context
	function drawBatt(dc) {
		var batval = Sys.getSystemStats().battery.toLong();
		// Draw with appropriate color for battery level
		if ( 20.0 >= batval && 10 < batval ) {
			dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
		}
		else if ( 10.0 >= batval ) {
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
		}
		else {
			dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
		}
		var batStr = Lang.format("$1$%", [batval]);
		dc.drawText((3.2 * dc.getWidth()/ 4), (dc.getHeight() / 2) - 11, Gfx.FONT_XTINY, batStr, Gfx.TEXT_JUSTIFY_CENTER); 
	}
	
    // Handle the update event
    function onUpdate(dc) {
        var width;
        var height;
        var screenWidth = dc.getWidth();
        var clockTime = Sys.getClockTime();
        var hourHand;
        var minuteHand;
        
        width = dc.getWidth();
        height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);

        // Clear the screen
        dc.clear();	
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        // Draw the numbers
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width / 2), 8, Gfx.FONT_SMALL, "12", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width - 13, (height / 2) - 15, Gfx.FONT_SMALL, "3", Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width / 2, height - 35, Gfx.FONT_SMALL, "6", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(13, (height / 2) - 15, Gfx.FONT_SMALL, "9", Gfx.TEXT_JUSTIFY_LEFT);

        // Draw the date
        dc.drawText(width / 2, (2.7 * height / 4), Gfx.FONT_TINY, dateStr, Gfx.TEXT_JUSTIFY_CENTER);

		// Draw the battery percentage
		drawBatt(dc);
		
		// Draw bluetooth line if connected
		drawBluetooth(dc);
		// Draw notification indicator
		drawNotificationCount(dc);
		// Draw step goal arc
		drawStepArc(dc);
		// Draw the move arc
		drawMoveArc(dc);
        // Draw the hash marks
        drawHashMarks(dc);
        // Draw the alarm icon
        drawAlarm(dc);

        // Draw the hour. Convert it to minutes and compute the angle.
        hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHand = hourHand / (12 * 60.0);
        hourHand = hourHand * Math.PI * 2;
       	drawHourHand(dc, hourHand);
       	
        // Draw the minute
        minuteHand = (clockTime.min / 60.0) * Math.PI * 2;
        drawMinuteHand(dc, minuteHand);

        // Draw the second
//        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
//        secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
//        secondTail = secondHand - Math.PI;
//        drawSecondHand(dc, secondHand);

        // Draw the arbor
        // Outer arbor
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(width / 2, height / 2, 7);
        // Inner arbor
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 3);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(width / 2, height / 2, 3);
    }

    function onEnterSleep() {
        //isAwake = false;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        isAwake = true;
    }
}
