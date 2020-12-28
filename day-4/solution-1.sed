#!/usr/bin/sed -nf


# read the input, line by line, until an empty line is encountered
# once encountered, the hold space will have the entire set of records we want
:merge

/:/ {
	
	# if the hold space is empty, we want 'h' (avoid appending newline)
	# otherwise, we want 'H' (append newline)
	#
	# temporarily swap hold and pattern spaces so we can match against the
	# hold space to determine if it's empty or not
	x
	/./ {
		x
		H
	}
	/^$/ {
		x
		h
	}

	# if this is the last line, process the last results
	$ b done

	# let's read the next line now
	n

	# loop back to the top and try again
	b merge
}

:done

# grab the hold space
x

# check if the pattern space has all the required fields
# if any are missing, replace the pattern space with INVALID
/byr:/ ! b invalid
/iyr:/ ! b invalid
/eyr:/ ! b invalid
/hgt:/ ! b invalid
/hcl:/ ! b invalid
/ecl:/ ! b invalid
/pid:/ ! b invalid

# if all required fields are present, print the record
# (we only need to print valid ones, not invalid ones)
s/\n\+/ /g
p

# if we encountered an invalid one, just move on and print nothing
:invalid

# if we are at the end, print the line number (which corresponds to the number
# of valid records)
n

b merge

