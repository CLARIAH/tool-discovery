tooldiscovery.pdf:
	pdflatex tooldiscovery
	biber tooldiscovery
	pdflatex tooldiscovery
	pdflatex tooldiscovery

presentation.pdf:
	pandoc -t beamer presentation.md -o $@

marketplace-dariahconf.pdf: marketplace-dariahconf.tex
	pdflatex marketplace-dariahconf
	biber marketplace-dariahconf
	pdflatex marketplace-dariahconf
	pdflatex marketplace-dariahconf

compliance.png: compliance.csv
	gnuplot -p -e 'set term png size 800,300; set size ratio 0.375; set output "compliance.png"; set datafile separator ","; set style fill solid; set sty d hist; set xlabel "Compliance level"; set ylabel "Percentage"; set yrange [0:50]; plot "compliance.csv" u 2:xtic(1) notitle'
