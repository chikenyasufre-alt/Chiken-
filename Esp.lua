local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Camera=workspace.CurrentCamera
local LocalPlayer=Players.LocalPlayer

local ESPEnabled=true
local BoxEnabled=true
local LineEnabled=true
local WeaponEnabled=true
local FOVEnabled=true
local FOVSize=150
local ESPObjects={}

local FOVCircle=Drawing.new("Circle")
FOVCircle.Visible=true
FOVCircle.Radius=FOVSize
FOVCircle.Thickness=2
FOVCircle.Filled=false
FOVCircle.Transparency=1

local function RemoveESP(p)
 if ESPObjects[p] then
  for _,o in pairs(ESPObjects[p]) do pcall(function() o:Remove() end) end
  ESPObjects[p]=nil
 end
end

local function CreateESP(p)
 if p==LocalPlayer then return end
 RemoveESP(p)
 local box=Drawing.new("Square")
 box.Thickness=2
 box.Filled=false
 box.Visible=false
 local line=Drawing.new("Line")
 line.Thickness=1
 line.Visible=false
 local weapon=Drawing.new("Text")
 weapon.Size=13
 weapon.Center=true
 weapon.Outline=true
 weapon.Visible=false
 ESPObjects[p]={Box=box,Line=line,Weapon=weapon}
end

for _,p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local function GetWeapon(c)
 if not c then return "Sin arma" end
 local t=c:FindFirstChildOfClass("Tool")
 return t and t.Name or "Sin arma"
end

RunService.RenderStepped:Connect(function()
 local viewport=Camera.ViewportSize
 FOVCircle.Visible=FOVEnabled
 FOVCircle.Radius=FOVSize
 FOVCircle.Position=Vector2.new(viewport.X/2,viewport.Y/2)

 for p,o in pairs(ESPObjects) do
  local c=p.Character
  local h=c and c:FindFirstChildOfClass("Humanoid")
  local r=c and c:FindFirstChild("HumanoidRootPart")

  if ESPEnabled and c and h and h.Health>0 and r then
   local cf,size=c:GetBoundingBox()
   local top=cf.Position+Vector3.new(0,size.Y/2,0)
   local bottom=cf.Position-Vector3.new(0,size.Y/2,0)
   local ts,tv=Camera:WorldToViewportPoint(top)
   local bs,bv=Camera:WorldToViewportPoint(bottom)

   if tv or bv then
    local height=math.abs(ts.Y-bs.Y)
    local width=height*.55

    o.Box.Visible=BoxEnabled
    o.Box.Size=Vector2.new(width,height)
    o.Box.Position=Vector2.new(ts.X-width/2,ts.Y)

    o.Line.Visible=LineEnabled
    o.Line.From=Vector2.new(viewport.X/2,viewport.Y)
    o.Line.To=Vector2.new(ts.X,bs.Y)

    o.Weapon.Visible=WeaponEnabled
    o.Weapon.Text=GetWeapon(c)
    o.Weapon.Position=Vector2.new(ts.X,ts.Y-18)
   else
    o.Box.Visible=false
    o.Line.Visible=false
    o.Weapon.Visible=false
   end
  else
   o.Box.Visible=false
   o.Line.Visible=false
   o.Weapon.Visible=false
  end
 end
end)

_G.ToggleESP=function() ESPEnabled=not ESPEnabled end
_G.ToggleBox=function() BoxEnabled=not BoxEnabled end
_G.ToggleLine=function() LineEnabled=not LineEnabled end
_G.ToggleWeapon=function() WeaponEnabled=not WeaponEnabled end
_G.ToggleFOV=function() FOVEnabled=not FOVEnabled end
_G.SetFOV=function(size) FOVSize=math.clamp(size,25,500) end
