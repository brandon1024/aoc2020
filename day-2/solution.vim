fun! Solve()
	let l:validpass_p1 = 0
	let l:validpass_p2 = 0

	let l:linecount = line('$')

	let l:i = 1
	while l:i <= l:linecount
		let l:components = matchlist(getbufline("%", l:i), '\(\d\+\)-\(\d\+\) \(\a\)\: \(\a\+\)')

		let l:lower = l:components[1]
		let l:upper = l:components[2]
		let l:cmatch = l:components[3]
		let l:pass = l:components[4]

		let l:clist = split(l:pass, '\zs')
		let l:ccount = count(l:clist, l:cmatch)

		" part 1
		if l:ccount >= l:lower && l:ccount <= l:upper
			let l:validpass_p1 += 1
		endif

		" part 2
		let l:passlen = strlen(l:pass)
		
		" lower and upper are 1-indexed
		if l:passlen < l:lower || l:passlen < l:upper
			echoe "invalid input line: " l:pass
		else
			if l:clist[l:lower - 1] == l:cmatch && l:clist[l:upper - 1] != l:cmatch
				let l:validpass_p2 += 1
			elseif l:clist[l:lower - 1] != l:cmatch && l:clist[l:upper - 1] == l:cmatch
				let l:validpass_p2 += 1
			endif
		endif

		let l:i += 1
	endwhile

	echom "[part 1] valid passwords: " l:validpass_p1
	echom "[part 2] valid passwords: " l:validpass_p2
endfun

call Solve()
