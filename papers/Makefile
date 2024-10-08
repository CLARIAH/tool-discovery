tooldiscovery.pdf:
	pdflatex tooldiscovery
	biber tooldiscovery
	pdflatex tooldiscovery
	pdflatex tooldiscovery

presentation.pdf:
	pandoc -t beamer presentation.md -o $@

compliance.png: compliance.csv
	gnuplot -p -e 'set term png; set output "compliance.png"; set datafile separator ","; set style fill solid; set sty d hist; set xlabel "Compliance level"; set ylabel "Percentage"; set yrange [0:50]; plot "compliance.csv" u 2:xtic(1) notitle'
