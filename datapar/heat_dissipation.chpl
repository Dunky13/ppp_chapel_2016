use util;
use Time;
use VisualDebug;
use BlockDist;
/*use DimensionalDist2D, ReplicatedDim, BlockCycDim;*/

config const N = 150;
config const M = 100;
config const I = 42;
config const E = 0.1;
config const L = -100.0;
config const H = 100.0;
config const P = 1;
config const C = "../images/pat1_150x100.pgm";
config const T = "../images/pat2_150x100.pgm";
/*config const C = "/home/hphijma/images/pat1_150x100.pgm";
config const T = "/home/hphijma/images/pat2_150x100.pgm";*/
config const help_params = false;

/* Add your code here */
/*const block = new Block({1..N, 1..M});*/
const Space = {1..N, 1..M};
const D: domain(2) dmapped Block(boundingBox=Space) = Space; // dmapped new Block({1..N, 1..M});
print_parameters();

const tinit: [D] real;
readpgm(T, N, M, {1..N, 1..M}, tinit, L, H);

const tcond: [D] real;
readpgm(C, N, M, {1..N, 1..M}, tcond, 0.0, 1.0);

proc getRelativeWeight(map: [D] real, i: int, j:int, weight: real){
	return weight * map(i,j) * abs(tcond(i,j)-1);
}
proc calcRes(map: [D] real, i: int, j:int){
	const directN: real = sqrt(2)/(sqrt(2)+1);
	const diagonN: real = 1/sqrt(2)+1;

	var directRes: real = getRelativeWeight(map, i-1, j, directN) +
												getRelativeWeight(map, i+1, j, directN) +
												getRelativeWeight(map, i, j-1, directN) +
												getRelativeWeight(map, i, j+1, directN);

	var diagonRes: real = getRelativeWeight(map, i-1, j-1, diagonN) +
												getRelativeWeight(map, i+1, j+1, diagonN) +
												getRelativeWeight(map, i+1, j-1, diagonN) +
												getRelativeWeight(map, i-1, j+1, diagonN);
	return (directRes + diagonRes)/8;
}

proc do_compute() {
  /* your main function */
  var r : results;
  var t : Timer;

  t.start();

	var final: [D] real = tinit[D];
	var tmp : [D] real;
	r.niter = 0;
	/*startVdebug("vdata");*/
	do{

		/*[(i,j) in D] tmp(i,j) = calcRes(final, i,j);*/
		coforall (i,j) in D do
			tmp(i,j) = calcRes(final, i, j);
		const delta = max reduce abs(final(D) - tmp(D));

		final[D] = tmp[D];
		r.niter += 1;
	}while(delta > E && r.niter < I);
	r.tmin = min reduce final(D);
	r.tmax = max reduce final(D);
	r.maxdiff = r.tmax -r.tmin;
	r.tavg	= (+ reduce final(D)) / (N*M)**2;


  t.stop();

  r.time = t.elapsed();
	/*stopVdebug();*/
  return r;
}

/* End add your code here */

util.main();
