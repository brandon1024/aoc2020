BEGIN {
	RS=""
	p1=0
	p2=0
}

{
	flen=split($0, fields, "\n")
	gsub(/[^a-z]/, "")
	split($0, chars, "")

	for (c=97; c <= 122; c++) {
		s=sprintf("%c", c)
		p2 += gsub(s, s, $0) == flen
	}

	for (i in chars)
		p1 += !index(substr($0, 0, i), chars[i])
}

END {
	printf("[part 1] sum of counts: %d\n", p1)
	printf("[part 2] sum of counts: %d\n", p2)
}

