![alt text](https://github.com/Shambi-0/Proxhook/blob/main/Images/cd87dd9576de7257e781d678a9732d0a9df8c0ea.png "Proxhook")

# A Module for proxying discord webhooks!
___

# Features
#### Managed Requests!
> Using the rate-limit information Hyra provides, Requests that are being rate-limited are stored until the rate-limit window has reset. in other words : if your request is valid, it won’t get dropped.

#### Simple Usage!
> A Discord webhook should be structured similar to this :
> `https://discord.com/api/webhooks/ID/TOKEN`
> and using Proxhook is just a matter of plugging in the ID, TOKEN, & the data you want to send.
```lua
local Proxhook = require(script.Proxhook);

local Success = Proxhook(ID, TOKEN, DATA); -- <@Success> : boolean
```

___

## References :
- The original Devforum Post can be found [here](https://devforum.roblox.com/t/proxhook-a-module-for-proxying-discord-webhooks/1505544).
- The officially uploaded version can be found [here](https://www.roblox.com/library/7719426842/Proxhook)!

## Credits :
- The Logo, Name, Source-Code, And Publication is by **Luc Rodriguez** (Aliases : Shambi, StyledDev)
- All credit for [Hyra](https://hyra.io/) goes to it's Contributors, of which can be found with it's Source-Code [here](https://github.com/hyra-io/Discord-Webhook-Proxy).
