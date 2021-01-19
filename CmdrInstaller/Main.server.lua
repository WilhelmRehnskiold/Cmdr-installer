--!strict
local toolbar = plugin:CreateToolbar("Cmdr Installer")
local button = toolbar:CreateButton("Install Cmdr", "Installs the latest version of Cmdr", "rbxassetid://711219057")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ServerScriptService = game:GetService("ServerScriptService")

local function install(asset, location)
	if location:FindFirstChild(asset.Name) then
		location:FindFirstChild(asset.Name):Destroy()
	end
	asset.Parent = location
end

local function non_critical_install(asset,location)
	if location:FindFirstChild(asset.Name) then
		asset:Destroy()
		return nil
	else
		asset.Parent = location
		return asset
	end
end

local function HttpEnabled()
	--kind of works except if the user has no internet connection
	local succes = pcall(function()
		game:GetService('HttpService'):GetAsync('http://www.google.com/')
	end)
	return succes
end

local function sys_install()
	local start_time = tick()

	local install_folder = script.Parent.Install
	--legacy support
	if ServerScriptService:FindFirstChild("Cmdr") then
		if ServerScriptService:FindFirstChild("Cmdr").ClassName == "ModuleScript" then
			ServerScriptService:FindFirstChild("Cmdr"):Destroy()
			if ServerScriptService:FindFirstChild("CmdrServer") then
				ServerScriptService:FindFirstChild("CmdrServer"):Destroy()
			end
		end
	end
	--ServerFolder install
	local folder = Instance.new("Folder")
	folder.Name = "Cmdr"
	non_critical_install(folder, ServerScriptService)
	install(install_folder.Cmdr.Cmdr:Clone(), ServerScriptService.Cmdr)
	--Server script install
	local server_script = install_folder.Cmdr.CmdrServer:Clone()
	local result = non_critical_install(server_script, ServerScriptService.Cmdr)
	if result ~= nil then server_script.Disabled = false end
	--hook install
	non_critical_install(install_folder.Cmdr.Hooks:Clone(), ServerScriptService.Cmdr)
	--client install
	local local_script = install_folder.CmdrClient:Clone()
	local result = non_critical_install(local_script, game:GetService("StarterPlayer").StarterPlayerScripts)
	if result ~= nil then 
		local_script.Disabled = false
		plugin:OpenScript(local_script, 6)
	end
	
	if HttpEnabled() == false then
		warn("You should enable HttpService!")
	end
	
	ChangeHistoryService:SetWaypoint("Installed Cmdr")
	print("Finished installation in: " .. tick()-start_time .. " ticks")
end

button.Click:Connect(sys_install)
