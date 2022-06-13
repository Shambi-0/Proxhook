--[[


██████╗░██████╗░░█████╗░██╗░░██╗██╗░░██╗░█████╗░░█████╗░██╗░░██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗██╔╝██║░░██║██╔══██╗██╔══██╗██║░██╔╝
██████╔╝██████╔╝██║░░██║░╚███╔╝░███████║██║░░██║██║░░██║█████═╝░
██╔═══╝░██╔══██╗██║░░██║░██╔██╗░██╔══██║██║░░██║██║░░██║██╔═██╗░
██║░░░░░██║░░██║╚█████╔╝██╔╝╚██╗██║░░██║╚█████╔╝╚█████╔╝██║░╚██╗
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝


Discription : A Proxy module for using webhooks, Default proxy is 'Hyra.io'.

Credits :
	
	StyledDev (roblox.com/users/2391664934/profile) - [For this module]
	samueIox (roblox.com/users/121647898/profile) - [For Hyra.io]

Check out Proxhook on the devforum :
	https://devforum.roblox.com/t/proxhook-a-module-for-proxying-discord-webhooks/1505544

Or on Github :
	https://github.com/Shambi-0/Proxhook

Aswell as Hyra : 
	https://devforum.roblox.com/t/discord-webhook-proxy/1500688

--]]

--------------------------
--// Type Definitions //--
--------------------------

type Dictionary<Type> = {[string] : Type};
type Array<Type> = {[number] : Type};

type Dataset = (string | {[any] : any})?

------------------
--// Services //--
------------------

-- Service used for sending & receiving http requests over the internet.
local HttpService : HttpService = game:GetService("HttpService");

-------------------
--// Variables //--
-------------------

-- Hyra Proxy Url, Which will be further modified.
local Url : string = "https://hooks.hyra.io/api/webhooks/%s/%s";

--[[
Stores the information required
to work with the rate limit.
--]]
local RateLimit : Dictionary<number> = {

	Reset = 0, --> When this rate limiting window will reset.
	Limit = 0xf, --> How many requests in this window you have remaining.
	Retry = 0  --> The amount of seconds you have left on the rate limit.
};

--[[
Requests caught up in the Rate limit will be
stored in 'Cache' until the rate limit is over.
--]]
local Cache : Array<Array<string>> = {};

-------------------
--// Functions //--
-------------------

-- Sends the remaining requests stored in 'Cache'.
function UpdateCache()

	-- The remaining requests that did not make it, will be put back into the 'Cache'.
	local Left : Array<Array<string>> = {};

	-- Cycle through the remaining requests.
	for _, Data : Array<string> in ipairs(Cache) do

		-- Check if we are operating under the rate limit.
		if (0 < RateLimit.Limit) then

			-- Unpack the request and post it to the cached 'Destination'.
			local Response = HttpService:PostAsync(unpack(Data)); --> Example Request : '{Destination : string, Data : string}'

			if (Response ~= "") then

				-- Create a direct reference to the headers given in the response.
				local Headers : Dictionary<any> = Response.Headers;

				-- Update rate limit stats based off headers.
				RateLimit.Reset = Headers["x-ratelimit-reset"];
				RateLimit.Limit = Headers["x-ratelimit-remaining"];

				-- check if a response body was provided.
				if (Response.Body ~= "") then

					-- if so, decode body from json to a table.
					local Decoded : Dictionary<any> = HttpService:JSONDecode(Response.Body);

					-- Update rate limit stat based off the response body.
					RateLimit.Retry = if (typeof(Decoded.retry_after) == "number") then Decoded.retry_after else 0;
				end;
			end;
		else
			--[[
			If we are over the rate limit, then
			Add the Request back to 'Cache' to
			be sent the next update session.
			--]]
			table.insert(Left, Data);
		end;
	end;

	-- Update 'Cache' to contain the remaining requests.
	Cache = Left;
	return;
end;

----------------------
--[[ Finalization ]]--
----------------------

return (function(Id : string | number, Token : string, Data : Dataset) : boolean

	-- Catch possible issues, and log messages accordingly.
	assert(typeof(Token) == "string", "Proxhook : \"Token\" is expected to be a \"string\".");
	assert(not (typeof(Id) ~= "string" and typeof(Id) ~= "number"), "Proxhook : \"Id\" is expected to be either a \"string\" or a \"number\".");

	-- Format url so it may be used to proxy requests.
	local FormattedUrl : string = string.format(Url, Id, Token);

	--[[
	Pass through a pcall to catch error that
	may occur when sending an http request.
	--]]
	local Success : boolean, Error : string | nil = pcall(function()

		-- Convert Data into a string if it's not already.
		local Processed : string = type(Data) == "string" and Data or HttpService:JSONEncode(Data);

		-- Add Request to cache to be managed further.
		table.insert(Cache, {FormattedUrl, Processed});

		-- Update Cache to send remaining & new requests.
		UpdateCache();
	end);

	if (Error) then
		warn(string.format("Proxhook : %s", Error))
	end;

	--[[
	Return a boolean value
	to indecate the success
	and to make this function valid.
	--]]
	return (Success);
end);
