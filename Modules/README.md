# Simply Love Modules
If one wants to write code that needs to run on specific screens, Simply Love defines this notion of "modules". This is useful if one wants to incorporate third-party code into the theme without needing to edit the Simply Love files directly.

## Inner Workings
When StepMania loads, we load all the `*.lua` files in the `/Modules` directory. These modules must define and return a table where each entry in the table is a mapping from ScreenName to a single Actor/ActorFrame. These Actors will later get accumulated and added as child ActorFrames of ScreenSystemLayer. Every Actor must at least have a `ModuleCommand`. This is what gets executed whenever we load into a new screen.

When defining variables, remember to not have globals as they may pollute the global namespace.

For example, a module may look like the following:

```lua
local t = {}

t["ScreenSelectMusic"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SCREENMAN:SystemMessage("hello from ScreenSelectMusic")
    end
}

t["ScreenGameplay"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SCREENMAN:SystemMessage("hello from ScreenGameplay")
    end
}

return t
```

In the above example, we will simply SystemMessage a string once we load `ScreenSelectMusic` and `ScreenGameplay` respectively.
