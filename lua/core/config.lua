--[[
	Shine's config system.
]]

local Encode, Decode = json.encode, json.decode
local Notify = Shared.Message
local Open = io.open
local StringFormat = string.format

local JSONSettings = { indent = true, level = 1 }

local ConfigPath = "config://shine\\BaseConfig.json"
local BackupPath = "config://Shine_BaseConfig.json"

function Shine.LoadJSONFile( Path )
	local File, Err = Open( Path, "r" )

	if not File then
		return nil, Err
	end

	local Ret = Decode( File:read( "*all" ) )

	File:close()

	return Ret
end

function Shine.SaveJSONFile( Table, Path )
	local File, Err = Open( Path, "w+" )

	if not File then
		return nil, Err
	end

	File:write( Encode( Table, JSONSettings ) )

	File:close()

	return true
end

function Shine:LoadConfig()
	local ConfigFile = self.LoadJSONFile( ConfigPath )

	if not ConfigFile then
		ConfigFile = self.LoadJSONFile( BackupPath )
		
		if not ConfigFile then
			self:GenerateDefaultConfig( true )

			return
		end
	end

	Notify( "Loading Shine config..." )

	self.Config = ConfigFile
end

function Shine:SaveConfig()
	local ConfigFile, Err = self.SaveJSONFile( self.Config, ConfigPath )

	if not ConfigFile then --Something's gone horribly wrong!
		Shine.Error = "Error writing config file: "..Err
		
		Notify( Shine.Error )
		
		return
	end

	Notify( "Saving Shine config..." )
end

function Shine:GenerateDefaultConfig( Save )
	self.Config = {
		EnableLogging = true, --Enable Shine's internal log. Note that plugins rely on this to log.
		LogDir = "config://shine\\logs\\", --Logging directory.
		DateFormat = "dd-mm-yyyy", --Format for logging dates.

		ExtensionDir = "config://shine\\plugins\\", --Plugin configs directory.

		GetUsersFromWeb = false, --Sets whether user data should be retrieved from the web.
		UsersURL = "http://www.yoursite.com/users.json", --URL to get user data from if the above is true.

		ActiveExtensions = { --Defines which plugins should be active.
			adverts = false,
			afkkick = false,
			badges = false,
			ban = true,
			basecommands = true,
			funcommands = false,
			logging = false,
			mapvote = true,
			motd = true,
			serverswitch = false,
			unstuck = true,
			voterandom = false,
			votescramble = false,
			votesurrender = true,
			welcomemessages = false
		},

		EqualsCanTarget = false, --Defines whether users with the same immunity can target each other or not.

		ChatName = "Admin", --The default name that should appear for notifications with a name (unless in legacy mode, not all messages will show this.)

		SilentChatCommands = true, --Defines whether to silence all chat commands, or only those starting with "/".
	}

	if Save then
		self:SaveConfig()
	end
end

function Shine:LoadExtensionConfigs()
	self:LoadConfig()

	Notify( "Loading extensions..." )

	for Name, Enabled in pairs( self.Config.ActiveExtensions ) do
		if Enabled then
			local Success, Err = Shine:LoadExtension( Name )
			Notify( Success and StringFormat( "- Extension '%s' loaded.", Name ) or StringFormat( "- Error loading %s: %s", Name, Err ) )
		end
	end

	Notify( "Completed loading Shine extensions." )
end

Shine:LoadExtensionConfigs()

if not Shine.Error then
	Shine.Hook.Call( "PostloadConfig" )
end
