PackAdd = function(package, version) 
	version = version or "main"	

	vim.pack.add({{ src = "http://github.com/" .. package, version = version }})
end		

