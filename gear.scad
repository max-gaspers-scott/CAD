// Two involute spur gears on a base plate with axle pegs (units: mm)
// Set assembled = true to preview the gears meshed on the pegs,
// false for a print layout with every part flat on the bed.

assembled = false;

teeth_a        = 18;   // big gear: 40 mm (~1.6 in) outside diameter
teeth_b        = 12;   // small gear: 28 mm (~1.1 in) outside diameter
gear_module    = 2;    // tooth size (pitch diameter / teeth)
pressure_angle = 20;   // degrees
thickness      = 8;    // gear face width

peg_d          = 5;    // axle peg diameter
peg_clearance  = 0.5;  // extra diameter on gear bore so it spins freely
backlash       = 0.3;  // extra spacing between pegs so teeth don't bind

plate_h        = 3;    // base plate thickness
plate_margin   = 4;    // plate border past the gear tips
peg_h          = thickness + 2;  // peg height above the plate
$fn = 64;

bore_d   = peg_d + peg_clearance;
center_d = gear_module * (teeth_a + teeth_b) / 2 + backlash;

function pitch_r(teeth) = gear_module * teeth / 2;
function outer_r(teeth) = pitch_r(teeth) + gear_module;          // addendum
function root_r(teeth)  = pitch_r(teeth) - 1.25 * gear_module;   // dedendum
function base_r(teeth)  = pitch_r(teeth) * cos(pressure_angle);

// point on involute curve at roll angle t (degrees)
function involute(r, t) =
    [r * (cos(t) + t * PI / 180 * sin(t)),
     r * (sin(t) - t * PI / 180 * cos(t))];

// roll angle where involute reaches radius r
function roll_at(rb, r) = sqrt(pow(r / rb, 2) - 1) * 180 / PI;

function rotate_pt(p, a) = [p[0] * cos(a) - p[1] * sin(a),
                            p[0] * sin(a) + p[1] * cos(a)];

function mirror_y(p) = [p[0], -p[1]];

module tooth(teeth) {
    steps = 12;
    rb    = base_r(teeth);
    t_max = roll_at(rb, outer_r(teeth));
    // angle of involute at pitch circle, used to center the tooth
    p_p   = involute(rb, roll_at(rb, pitch_r(teeth)));
    half  = 90 / teeth + atan2(p_p[1], p_p[0]);   // half tooth angle at base circle
    side  = [for (i = [0:steps]) rotate_pt(involute(rb, t_max * i / steps), -half)];
    polygon(concat(
        [[0, 0]],
        [for (p = side) mirror_y(p)],
        [for (i = [steps:-1:0]) side[i]]
    ));
}

module gear(teeth) {
    linear_extrude(height = thickness)
        difference() {
            union() {
                circle(r = root_r(teeth));
                intersection() {
                    circle(r = outer_r(teeth));
                    for (i = [0:teeth - 1])
                        rotate(i * 360 / teeth) tooth(teeth);
                }
            }
            circle(d = bore_d);
        }
}

plate_w = 2 * (outer_r(teeth_a) + plate_margin);
plate_l = center_d + outer_r(teeth_a) + outer_r(teeth_b) + 2 * plate_margin;

module platform() {
    // plate spans from the big gear's edge to the small gear's edge
    translate([-outer_r(teeth_a) - plate_margin, -plate_w / 2, 0])
        cube([plate_l, plate_w, plate_h]);
    for (x = [0, center_d])
        translate([x, 0, plate_h]) {
            cylinder(h = peg_h - 0.5, d = peg_d);
            // small chamfer on top so gears slide on easily
            translate([0, 0, peg_h - 0.5])
                cylinder(h = 0.5, d1 = peg_d, d2 = peg_d - 1);
        }
}

platform();

if (assembled) {
    // small lift so gears sit just above the plate
    translate([0, 0, plate_h + 0.5]) gear(teeth_a);
    // rotate half a tooth so the small gear's gap faces the big gear's tooth
    translate([center_d, 0, plate_h + 0.5])
        rotate(teeth_b % 2 == 0 ? 180 / teeth_b : 0) gear(teeth_b);
} else {
    // lay the gears out beside the plate for printing
    gap = 6;
    translate([0, plate_w / 2 + gap + outer_r(teeth_a), 0]) gear(teeth_a);
    translate([outer_r(teeth_a) + gap + outer_r(teeth_b), plate_w / 2 + gap + outer_r(teeth_b), 0])
        gear(teeth_b);
}
