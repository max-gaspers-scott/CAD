raid = 10;

leng = 30;
num = 25;

housing_r = 30;     // inner radius of the housing
clearance = 0.5;    // gap between blade tips and housing wall
rotor_r = housing_r - clearance;

intersection() {
    union() {
        for (i = [0 : num - 1]){
            rotate([90,0, i * (360 / num)]) translate([0,0,leng/2]) difference() {
                // 1. Primary shape (what you keep)
                cylinder(h= leng - 0.1, r = raid, center = true);
                // 2. Cutting shape (what gets removed)
                cylinder(h = 40, r = raid - 1, center = true);
                translate([0,-10,-20])
            cube([40,20,40]);
            translate([-40,-20,-20])
            cube([80,20,80]);
            }
        }
        translate([0,0,5])
        cylinder(h=10, r=25, center=true);
    }

    // trim blade tips to a clean circle
    cylinder(h = 100, r = rotor_r, center = true, $fn = 200);
}
#cylinder(h=20, r=25, center=true);
