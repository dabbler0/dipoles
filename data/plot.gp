set title "Plot"
set terminal pngcairo size 350,262 enhanced font 'Verdana,10'
set output 'x-axis.data.png'
set xlabel "X"
set ylabel "Y"
plot "x-axis.data" using 1:2 title "" with lines
