

raid = 10;

leng = 30;
num = 25;
for (i = [0 : num]){
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

