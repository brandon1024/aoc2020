cmake_policy(SET CMP0007 OLD)

set(input_file "input.in")
file(READ "${input_file}" contents)

string(REGEX REPLACE ";" "\\\\;" contents "${contents}")
string(REGEX REPLACE "\n" ";" contents "${contents}")

function(part1)
	foreach(a ${contents})
		foreach(b ${contents})
			math(EXPR sum "${a} + ${b}")
			if (sum EQUAL 2020)
				math(EXPR product "${a} * ${b}")
				message("[part 1] the answer is ${product} [${a} * ${b}]")
				return()
			endif()
		endforeach()
	endforeach()
endfunction()

function(sort_number_list numbers result)
	set(temporary_sorted_list "")
	
	while(1)
		list(LENGTH numbers numbers_len)
		if (numbers_len EQUAL 0)
			break()
		endif()
		
		math(EXPR numbers_len "${numbers_len} - 1")
		set(smallest_num_index 0)
		foreach(i RANGE 0 ${numbers_len})
			list(GET numbers ${smallest_num_index} smallest_num)
			list(GET numbers ${i} current)
			
			if(current LESS smallest_num)
				set(smallest_num_index ${i}})
			endif()
		endforeach()
	
		list(GET numbers ${smallest_num_index} smallest_num)
		list(APPEND temporary_sorted_list ${smallest_num})
		list(REMOVE_AT numbers ${smallest_num_index})
	endwhile()

	set("${result}" ${temporary_sorted_list} PARENT_SCOPE)
endfunction()

function(part2)
	sort_number_list("${contents}" sorted_contents)

	foreach(a ${sorted_contents})
		if(a GREATER 2020)
			break()
		endif()
		
		foreach(b ${sorted_contents})
			math(EXPR sum "${a} + ${b}")
			if (sum GREATER 2020)
				break()
			endif()

			foreach(c ${sorted_contents})
				math(EXPR sum "${a} + ${b} + ${c}")
				if (sum EQUAL 2020)
					math(EXPR product "${a} * ${b} * ${c}")
					message("[part 2] the answer is ${product} [${a} * ${b} * ${c}]")
					return()
				endif()
			endforeach()
		endforeach()
	endforeach()

	message("[part 2] unexpected input, could not solve this problem")
endfunction()

part1()
part2()


