use <StepMotor_28BYJ-48.scad>;
use <Hub_28BYJ-48.scad>;
include <Bearing_6807-2RS.scad>;

// global rendering parameters
$fn = 24;

// library examples
// translate([100, 100, 10]) { StepMotor28BYJ(); }
// stepperHub(10, 7, 6, 3.1, 1.5, 2.75);
//translate([0, 0, 8]) bearing6807_2RS();
// bearingInnerStep(bearing6807_2RS_d - iFitAdjust, 2, 2);
//shoulderBase(2, 55, 9.1, 3.1);

// interference fit adjustment for 3D printer
iFitAdjust = .6;

// shoulder base parameters
shoulderBaseHeight = 3;
shoulderBaseDiameter = 55;
shaftBossDiameter = 10;
mountScrewDiameter = 3.1;
bearingStep = 2; // size in mm of bearing interface step
// joint parameters
hubHeight = 10;
hubRadius = 7;
shaftHeight = 6;
shaftRadius = 3.1;
setScrewRadius = 1.5;
setScrewHeight = 2.75;
spokeWidth = 3;
spokes = 6;
screwTabs = 4;
screwTabHeight = 4;
armLength = 200;
// misc
baseDeckExtension = 50;
// 8 is distance from shaft center to screw center on x axis
// 35 is screw center to screw center on y axis
shaftCenterToMountHoldCenterXAxis = 8;
mountHoleCenterToMountHoleCenter = 35;
leadScrewDiameter = 8;

/* Pieces in this model
** Shoulder:
*** Base plate
*** Top plate
*** Lower arm
*** Upper arm
** Forearm:
*** ?
** Hand:
*** ?
*/

// shoulder base
color([.7, .7, 1]) 
    shoulderBase(shoulderBaseHeight, shoulderBaseDiameter, shaftBossDiameter, mountScrewDiameter);
// shoulder stepper
rotate([0, 180, 0]) 
    translate([-8, 0, 10]) 
        StepMotor28BYJ();
// lower shoulder bearing
translate([0, 0, shoulderBaseHeight + bearingStep])
    %bearing6807_2RS();
// shoulder - arm joint 
color([1, .7, .7]) 
    translate([0, 0, shoulderBaseHeight + bearing6807_2RS_B]) 
        armLower(bearing6807_2RS_D + iFitAdjust, bearingStep, bearingStep, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, screwTabs, screwTabHeight, armLength);
// arm joint pieces
translate([-armLength, 0, shoulderBaseHeight + bearing6807_2RS_B + bearingStep])
    %bearing6807_2RS();
// arm stepper
rotate([0, 180, 0]) 
    translate([armLength - 8, 0, bearingStep * 2]) 
        StepMotor28BYJ();
// forearm pieces
translate([-armLength, 0, 0])
    forearmLower(bearing6807_2RS_D - iFitAdjust, bearing6807_2RS_D + iFitAdjust, bearingSteo, bearingStep, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, forearmLength);
/*
render() 
color([.1, .7, .1]) 
    translate([-armLength, 0, shoulderBaseHeight + bearing6807_2RS_B + (2* bearingStep)])
        armJointSpacer(bearing6807_2RS_d - iFitAdjust, bearing6807_2RS_D + iFitAdjust, bearingStep, shaftBossDiameter, mountScrewDiameter);
*/

//bearingInnerStep(bearing6807_2RS_d - iFitAdjust, 2, 2);
module bearingInnerStep(bearingID, stepHeight, stepWidth) {
    difference() {
        union() {
            // this fits inside of the bearing
            cylinder(h = stepHeight * 2, d = bearingID);
            // this rests on the bearing inner lip
            cylinder(h = stepHeight, d = bearingID + stepWidth);
        }
        // remove center
        cylinder(h = stepHeight * 2, d = bearingID - (stepWidth * 2));
    }
}

//translate([0, 0, 12]) bearingOuterStep(bearing6807_2RS_D + iFitAdjust, 2, 2);
module bearingOuterStep(bearingOD, stepHeight, stepWidth) {
    //render(convexivity = 3)
    difference() {
        cylinder(h = stepHeight * 2, d = bearingOD + stepWidth);
        cylinder(h = stepHeight * 2, d = bearingOD - stepWidth);
        cylinder(h = stepHeight, d = bearingOD);
    }
}


// armJointSpacer(bearing6807_2RS_D - iFitAdjust, bearing6807_2RS_D + iFitAdjust, bearingStep, shaftBossDiameter, mountScrewDiameter);
module armJointSpacer(bearingID, bearingOD, bearingStep, shaftBossDiameter, mountScrewDiameter) {
    union() {
        difference() {
            cylinder(h = bearingStep * 2, d = bearingOD + bearingStep);
            cylinder(h = bearingStep * 2, d = bearingID);
        }
        translate([0, 0, bearingStep * 2])
                bearingInnerStep(bearingID, bearingStep, bearingStep);
        // screw holes for joining to arm
        radial_array(vec = [0, 0, 1], n = screwTabs)
                translate([bearingOD / 2 + (setScrewRadius * 2), 0, (2 * bearingStep) - screwTabHeight])
                    difference() {
                        union () {
                            cylinder(h = screwTabHeight, r = setScrewRadius * 2);
                            translate([-2 * setScrewRadius, - 2 * setScrewRadius, 0])
                                cube([setScrewRadius * 2, 4 * setScrewRadius, screwTabHeight], center = false);
                        }
                        cylinder(h = screwTabHeight, r = setScrewRadius);
                    }       
    }
}


//shoulderBase(2, 55, 9.1, 3.1);
// WARNING: has some hard-coded non-parametric values in here!
module shoulderBase(shoulderBaseHeight, shoulderBaseDiameter, shaftBossDiameter, mountScrewDiameter) {
    mountHoleDepth = shoulderBaseHeight;

    //render(convexivity = 3)
    difference() {
        union () {
            cylinder(h = shoulderBaseHeight, d = shoulderBaseDiameter);
            translate([0, 0, shoulderBaseHeight])
                bearingInnerStep(bearing6807_2RS_d - iFitAdjust, bearingStep, bearingStep);
            // 40 is the length of deck extension from the baseplate in x
            translate([0, -shoulderBaseDiameter / 2, 0])
                cube([baseDeckExtension, shoulderBaseDiameter, shoulderBaseHeight], center = false);
        }
        // motor shaft hole
        cylinder(h = shoulderBaseHeight + (bearingStep * 2), d = shaftBossDiameter);
        // mounting holes
        
        translate([shaftCenterToMountHoldCenterXAxis, mountHoleCenterToMountHoleCenter/2, 0]) 
            cylinder(h = mountHoleDepth, d = mountScrewDiameter);
        translate([shaftCenterToMountHoldCenterXAxis, -mountHoleCenterToMountHoleCenter/2, 0]) 
            cylinder(h = mountHoleDepth, d = mountScrewDiameter);
        // lead screw hole
        translate([baseDeckExtension - (leadScrewDiameter * 1.5), 0, 0])
            cylinder(h = shoulderBaseHeight, d = leadScrewDiameter + (leadScrewDiameter / 2));
    }
    // NOTE: need to add LM8UU mounts
}




module armLower(bearingOD, stepHeight, stepWidth, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, screwTabs, screwTabHeight, armLength) {
    boundingBox = 12;
    boundingBoxHalf = boundingBox / 2;
    //
    armWidth = bearingOD + bearingStep;
    //render(convexivity = 3)
    union() {
        armInnerJoint(bearingOD, bearingStep, bearingStep, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, screwTabs, screwTabHeight);
        translate([-armLength, 0, 0])
            armOuterJointBase(bearingOD, bearingStep, setScrewRadius, screwTabs, screwTabHeight);
        difference() {
            translate([-armLength, -armWidth / 2, 0])
                cube([armLength, armWidth, bearingStep * 2], center=false);
            cylinder(h = bearingStep * 2, d = bearingOD);
            translate([-armLength, 0, 0])
                cylinder(h = bearingStep * 2, d = bearingOD);
            translate([-armLength + (bearingOD / 2) + (boundingBox / 2), -(armWidth / 2) + boundingBoxHalf, 0])
                cube([armLength - bearingOD - boundingBox, armWidth - boundingBox, bearingStep * 2], center = false);
        }
        difference() {
            intersection() {
            
            translate([-armLength + (bearingOD / 2) + (boundingBox / 2), -(armWidth / 2) + boundingBoxHalf, 0])
                cube([armLength - bearingOD - boundingBox, armWidth - boundingBox, bearingStep * 2], center = false);
            for (i = [ bearingOD / 2 : armWidth / 2 : armLength]) {
                translate([ -i, 0, bearingStep])
                    rotate([0, 0, 45])
                        cube([spokeWidth, armWidth + boundingBoxHalf, bearingStep * 2], center = true);
                translate([ -i, 0, bearingStep])
                    rotate([0, 0, -45])
                        cube([spokeWidth, armWidth + boundingBoxHalf, bearingStep * 2], center = true);
            }
        }
    }
   }
}

module armOuterJointBase(bearingOD, bearingStep, setScrewRadius, screwTabs, screwTabHeight) {
    mountHoleDepth = bearingStep * 2;

    union() {
/*
        //render(convexivity = 3)
    difference() {
        cylinder(h = bearingStep * 2, d = bearingOD + bearingStep);
        cylinder(h = bearingStep * 2, d = bearingOD - 2 * bearingStep);
    }
         // screw holes for joining to joint
        radial_array(vec = [0, 0, 1], n = screwTabs)
                translate([bearingOD / 2 + (setScrewRadius * 2), 0, (2 * bearingStep) - screwTabHeight])
                    difference() {
                        union () {
                            cylinder(h = screwTabHeight, r = setScrewRadius * 2);
                            translate([-2 * setScrewRadius, - 2 * setScrewRadius, 0])
                                cube([setScrewRadius * 2, 4 * setScrewRadius, screwTabHeight], center = false);
                        }
                        cylinder(h = screwTabHeight, r = setScrewRadius);
                    }    
*/
        difference() {
            union() {
                translate([0, 0, -(bearingStep * 2)])
                    cylinder(h = bearingStep * 2, d = bearingOD + bearingStep);
                translate([0, 0, bearingStep * 2])
                    rotate([0, 180, 0])
                        bearingOuterStep(bearingOD, bearingStep, bearingStep);
            }
            // motor shaft hole
            translate([0, 0, -(bearingStep * 2)])
                cylinder(h = shoulderBaseHeight + (bearingStep * 2), d = shaftBossDiameter);
            // mounting holes
            translate([0, 0, -(bearingStep * 2)]) {
                translate([shaftCenterToMountHoldCenterXAxis, mountHoleCenterToMountHoleCenter/2, 0]) 
                cylinder(h = mountHoleDepth, d = mountScrewDiameter);
                translate([shaftCenterToMountHoldCenterXAxis, -mountHoleCenterToMountHoleCenter/2, 0]) 
                cylinder(h = mountHoleDepth, d = mountScrewDiameter);
            }
        }
        
    }
}

//armInnerJoint(bearing6807_2RS_D + iFitAdjust, bearingStep, bearingStep, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, screwTabs, screwTabHeight);
module armInnerJoint(bearingOD, stepHeight, stepWidth, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, screwTabs, screwTabHeight) {
    //translate([0, 0, hubHeight - (2 * stepHeight)])
    union() {
        bearingOuterStep(bearingOD, stepHeight, stepWidth);
        // hub
        translate([0, 0, -(hubHeight - (2 * stepHeight))])
            stepperHub(hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight);
        // spokes
        radial_array(vec=[0, 0, 1], n = spokes)
                translate([hubRadius - (stepWidth / 2), -(spokeWidth / 2), stepHeight]) 
                    cube([(bearingOD / 2) - hubRadius, spokeWidth, stepHeight], center = false);
        // screw holes for joining to upper
        radial_array(vec = [0, 0, 1], n = screwTabs)
                translate([bearingOD / 2 + (setScrewRadius * 2), 0, (2 * stepHeight) - screwTabHeight])
                    difference() {
                        union () {
                            cylinder(h = screwTabHeight, r = setScrewRadius * 2);
                            translate([-2 * setScrewRadius, - 2 * setScrewRadius, 0])
                                cube([setScrewRadius * 2, 4 * setScrewRadius, screwTabHeight], center = false);
                        }
                        cylinder(h = screwTabHeight, r = setScrewRadius);
                    }
    }
}


module forearmLower(bearingID, bearingOD, stepHeight, stepWidth, hubHeight, hubRadius, shaftHeight, shaftRadius, setScrewRadius, setScrewHeight, spokeWidth, spokes, forearmLength) {
}



module copy_mirror(vec=[0,1,0]) { 
    children(); 
    mirror(vec)
        children(); 
} 

module radial_array(vec = [0,0,1], n = 4) {
    for ( i = [0 : n - 1] )
    {
        rotate( i * 360 / n, vec)
            children();
    }   
}