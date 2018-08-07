#!/bin/tcsh
kappa > /dev/null

wcsmosaic in=^$COHRS_SCRIPTS/in_inner1.txt out=$COHRS_TILED/inner1cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_inner2.txt out=$COHRS_TILED/inner2cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_inner3.txt out=$COHRS_TILED/inner3cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_middle1.txt out=$COHRS_TILED/middle1cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_middle2.txt out=$COHRS_TILED/middle2cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_outer1.txt out=$COHRS_TILED/outer1cube method=gauss params="[0,1]" variance genvar accept
wcsmosaic in=^$COHRS_SCRIPTS/in_outer2.txt out=$COHRS_TILED/outer2cube method=gauss params="[0,1]" variance genvar accept
