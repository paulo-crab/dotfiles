PackAdd = function(package, version) 
	
	local spec = { src = "https://github.com/" .. package }

  if version then
    spec.version = version
  end

  vim.pack.add({ spec })	
end		
	
