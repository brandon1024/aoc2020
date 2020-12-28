#!/usr/bin/sed -nEf

s/^(.*)$/ \1 /g

# four digits, at least 1920 and at most 2002
/byr:/ {
	# cannot be more than 4 digits
	/byr:[0-9]{5,} / b invalid

	# number must begin with 1 or 2
	/byr:[1,2]/ {

		# number must be 1920 < x < 2000
		/byr:19[2-9][0-9] / b valid1

		# number must be 2000 < x < 2003
		/byr:200[0-2] / b valid1

		b invalid
	}
	
	b invalid
}

:valid1

# four digits, at least 2010 and at most 2020
/iyr:/ {
	# cannot be more than 4 digits
	/iyr:[0-9]{5,} / b invalid

	/iyr:201[0-9] / b valid2
	/iyr:2020 / b valid2

	b invalid
}

:valid2

# four digits, at least 2020 and at most 2030
/eyr:/ {
	# cannot be more than 4 digits
	/eyr:[0-9]{5,} / b invalid

	/eyr:202[0-9] / b valid3
	/eyr:2030 / b valid3

	b invalid
}

:valid3

# a number followed by either cm or in
/hgt:/ {
	# if cm, the number must be at least 150 and at most 193
	/hgt:1[5-9][0-9]cm / {
		/hgt:19[4-9]cm / b invalid

		b valid4
	}

	# if in, the number must be at least 59 and at most 76
	/hgt:[5-7][0-9]in / {
		/hgt:5[0-8]in / b invalid
		/hgt:7[7-9]in / b invalid

		b valid4
	}

	b invalid
}

:valid4

# a '#' followed by exactly six hex digits
/hcl:/ {
	/hcl:#[0-9a-f]{6} / b valid5

	b invalid
}

:valid5

# exactly one of [amb, blu, brn, gry, grn, hzl, oth]
/ecl:/ {
	/ecl:((amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)) / b valid6
	
	b invalid
}

:valid6

# nine digit number, with leading zeroes
/pid:/ {
	/pid:[0-9]{9} / b valid7

	b invalid
}

:valid7

# print the record, given that all fields met validation
p

:invalid

