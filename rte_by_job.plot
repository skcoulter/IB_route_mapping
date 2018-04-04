# gnuplot commands to produce graph for switch route map
set title "Wolf Route Plot for Job 359588"
#set yrange [1:200] 
#set xrange [1:500] 
set style data histogram
set boxwidth 0.03
set ylabel "Number of Routes"
set xlabel "Switch Ports"
set xtics rotate
set xtics ("L219" 1,"S217B" 35,"S111B" 45,"S213B" 55,"L126" 65,"L203" 99,"L207" 133,"L128" 167,"S115B" 201,"S113B" 211,"L124" 221,"S117A" 255,"L221" 265,"S117B" 285,"L205" 295,"S215B" 329,"S115A" 339,"S215A" 349,"S211A" 359,"S209A" 369,"S217A" 379,"S111A" 389,"S213A" 399,"L201" 409,"L122" 443,"S113A" 453,"S211B" 463,"S209B" 473)
set terminal png truecolor small enhanced font 'Helvetica,10'
set output "/users/markus/route_maps/gnuplot/wolf_job.png"
plot "/users/markus/route_maps/routes.job359588" using 2 ti col fs solid lc rgb "#228B22"

