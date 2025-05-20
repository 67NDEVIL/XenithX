local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local textToCopy = "https://link-hub.net/1339131/v0xenhub"

-- Function to copy with feedback
local function copyWithFeedback(text)
    if not setclipboard then
        warn("Clipboard function not available")
        return false
    end
    
    setclipboard(text)
    
    -- Show notification if in-game
    if game:GetService("Players").LocalPlayer then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Copied to Clipboard",
            Text = "The Link has been copied to your clipboard",
            Duration = 5
        })
    end
    
    return true
end

-- Execute the copy
local success = copyWithFeedback(textToCopy)
if success then
    print("Text copied successfully: " .. textToCopy)
end


local Window = Rayfield:CreateWindow({
   Name = "V0xen Universal Aimbot 🔫 script",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "V0xen Hub",
   LoadingSubtitle = "by Iyce",
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "V0xen Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "V0xen AIMBOT HUB | KEY System",
      Subtitle = "Say good bye to the Fair Play",
      Note = "Best Roblox Aimbot Script ", -- Use this to tell the user how to get a key
      FileName = "IYC HUB", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://gist.githubusercontent.com/67NDEVIL/34679c4d1a689d51a09229e533c20ea1/raw/4cfa77aa4994e9dda28455d13a85afb3a46c8a6c/gistfile1.txt"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Aimbot")

-- Add Aim Part dropdown to select which part to aim at
local aimParts = {"Head", "Torso", "UpperTorso", "HumanoidRootPart"}
local AimPartDropdown
AimPartDropdown = MainTab:CreateDropdown({
    Name = "Aimbot Aim Part",
    Options = aimParts,
    CurrentOption = "Head",
    Flag = "AimbotAimPartDropdown",
    Callback = function(Value)
        local selected = type(Value) == "table" and Value[1] or Value
        if getgenv().Aimbot and getgenv().Aimbot.Settings then
            getgenv().Aimbot.Settings.LockPart = selected
        end
    end,
})

-- Add FOV slider to control aimbot FOV circle
local FOVSliderRayfield
FOVSliderRayfield = MainTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {20, 300},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "AimbotFOVSlider",
    Callback = function(Value)
        if getgenv().Aimbot and getgenv().Aimbot.FOVSettings then
            getgenv().Aimbot.FOVSettings.Amount = Value
            -- Update FOV GUI label if it exists
            if getgenv().Aimbot.FOVValue then
                getgenv().Aimbot.FOVValue.Text = "FOV: " .. Value
            end
        end
    end,
})

-- Add Smoothness slider to control aimbot smoothness
local SmoothnessSlider
SmoothnessSlider = MainTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0,
    Flag = "AimbotSmoothnessSlider",
    Callback = function(Value)
        if getgenv().Aimbot and getgenv().Aimbot.Settings then
            getgenv().Aimbot.Settings.Smoothness = Value
        end
    end,
})

Rayfield:Notify({
   Title = "You successfully executed!",
   Content = "By Iyce",
   Duration = 5,
   Image = nil,
})

-- Replace the Button with Toggle
local aimbotToggle
aimbotToggle = MainTab:CreateToggle({
   Name = "Enable Aim bot",
   CurrentValue = false,
   Callback = function(state)
      if state then
         --// Cache
         local select = select
         local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

         --// Preventing Multiple Processes
         pcall(function()
             if getgenv().Aimbot and getgenv().Aimbot.Functions then
                getgenv().Aimbot.Functions:Exit()
             end
         end)

         --// Environment
         getgenv().Aimbot = {}
         local Environment = getgenv().Aimbot

         --// Services
         local RunService = game:GetService("RunService")
         local UserInputService = game:GetService("UserInputService")
         local TweenService = game:GetService("TweenService")
         local Players = game:GetService("Players")
         local Camera = workspace.CurrentCamera
         local LocalPlayer = Players.LocalPlayer

         --// Variables
         local RequiredDistance, Typing, Animation, ServiceConnections = 2000, false, nil, {}
         local Running = false -- Start as not running, controlled by MB2

         --// Script Settings
         local selectedLockPart = AimPartDropdown and (type(AimPartDropdown.CurrentOption) == "table" and AimPartDropdown.CurrentOption[1] or AimPartDropdown.CurrentOption) or "Head"
         local selectedSmoothness = SmoothnessSlider and SmoothnessSlider.CurrentValue or 0
         Environment.Settings = {
             Enabled = true,
             TeamCheck = false,
             AliveCheck = true,
             WallCheck = false,
             Sensitivity = 0,
             ThirdPerson = false,
             ThirdPersonSensitivity = 3,
             TriggerKey = "MouseButton2",
             Toggle = false,
             LockPart = selectedLockPart,
             Smoothness = selectedSmoothness
         }

         Environment.FOVSettings = {
             Enabled = true,
             Visible = true,
             Amount = FOVSliderRayfield and FOVSliderRayfield.CurrentValue or 150,
             Color = Color3.fromRGB(255, 255, 255),
             LockedColor = Color3.fromRGB(255, 70, 70),
             Transparency = 0.5,
             Sides = 60,
             Thickness = 1,
             Filled = false
         }

         Environment.FOVCircle = Drawing.new("Circle")

         -- Sync Rayfield slider with aimbot FOV after initialization
         if FOVSliderRayfield and Environment.FOVSettings then
             FOVSliderRayfield:Set(Environment.FOVSettings.Amount)
         end

         --// Functions
         local function CancelLock()
             Environment.Locked = nil
             if Animation then Animation:Cancel() end
             Environment.FOVCircle.Color = Environment.FOVSettings.Color
         end

         local function GetClosestPlayer()
             if not Environment.Locked then
                 RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)
                 for _, v in next, Players:GetPlayers() do
                     if v ~= LocalPlayer then
                         if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                             if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                             if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                             if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

                             local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                             local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                             if Distance < RequiredDistance and OnScreen then
                                 RequiredDistance = Distance
                                 Environment.Locked = v
                             end
                         end
                     end
                 end
             elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
                 CancelLock()
             end
         end

         --// FOV Slider Logic (sync with Rayfield slider)
         if FOVSliderRayfield then
            FOVSliderRayfield:Set(Environment.FOVSettings.Amount)
         end

         --// Main
         local function Load()
             ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
                 if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
                     Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
                     Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
                     Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
                     Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
                     Environment.FOVCircle.Color = Environment.FOVSettings.Color
                     Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
                     Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
                     Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                 else
                     Environment.FOVCircle.Visible = false
                 end

                 if Running and Environment.Settings.Enabled then
                     GetClosestPlayer()
                     if Environment.Locked then
                         if Environment.Settings.ThirdPerson then
                             Environment.Settings.ThirdPersonSensitivity = mathclamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
                             local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
                             mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
                         else
                             local smoothness = Environment.Settings.Smoothness or 0
                             local targetPos = Environment.Locked.Character[Environment.Settings.LockPart].Position
                             if smoothness > 0 then
                                 -- Smoothly interpolate camera look direction
                                 local camPos = Camera.CFrame.Position
                                 local camLook = Camera.CFrame.LookVector
                                 local desiredLook = (targetPos - camPos).Unit
                                 local newLook = camLook:Lerp(desiredLook, math.clamp(smoothness, 0, 1))
                                 local newCFrame = CFrame.new(camPos, camPos + newLook)
                                 Camera.CFrame = newCFrame
                             elseif Environment.Settings.Sensitivity > 0 then
                                 Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, targetPos)})
                                 Animation:Play()
                             else
                                 Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                             end
                         end
                         Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
                     end
                 end
             end)

             -- Allow MB2 to control aimbot when toggle is ON
             ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
                 if not Typing and Environment.Settings.Enabled then
                     pcall(function()
                         if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                             Running = true
                         end
                     end)
                 end
             end)
             ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
                 if not Typing and Environment.Settings.Enabled then
                     pcall(function()
                         if Input.UserInputType == Enum.UserInputType.MouseButton2 then
                             Running = false
                             CancelLock()
                         end
                     end)
                 end
             end)
         end

         --// Functions
         Environment.Functions = {}

         function Environment.Functions:Exit()
             for _, v in next, ServiceConnections do
                 v:Disconnect()
             end
             if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end
             getgenv().Aimbot.Functions = nil
             getgenv().Aimbot = nil
         end

         --// Load
         Load()
      else
         -- Toggle OFF: Clean up aimbot
         pcall(function()
            if getgenv().Aimbot and getgenv().Aimbot.Functions then
               getgenv().Aimbot.Functions:Exit()
            end
         end)
      end
   end,
})

local HitboxTab = Window:CreateTab("Hitbox Expander 📦", nil)
local Section = HitboxTab:CreateSection("SilentAim")

local hitboxToggleSilent
hitboxToggleSilent = HitboxTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Callback = function(state)
      if state then
         -- Replacement: Root part hitbox expander (NEW VERSION)
         local Players = game:GetService("Players")
         local LocalPlayer = Players.LocalPlayer

         local function isEnemy(player)
             if player == LocalPlayer then return false end
             if player.Team ~= nil and LocalPlayer.Team ~= nil then
                 return player.Team ~= LocalPlayer.Team
             end
             return true
         end

         local function getRootParts(char)
             local roots = {}
             for _, part in ipairs(char:GetDescendants()) do
                 if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso") then
                     table.insert(roots, part)
                 end
             end
             return roots
         end

         local HITBOX_SIZE = Vector3.new(10, 10, 10) -- Big size
         local HITBOX_COLOUR = Color3.fromRGB(75,255,255)

         if not getgenv()._HBEConnections then getgenv()._HBEConnections = {} end

         local function expandHitbox(player)
             if player == LocalPlayer then return end
             local function onChar(char)
                 for _, root in ipairs(getRootParts(char)) do
                     pcall(function()
                         root.Size = HITBOX_SIZE
                         root.Color = HITBOX_COLOUR
                         root.CanCollide = false
                         root.Transparency = 0.5
                     end)
                 end
             end
             local charConn = player.CharacterAdded:Connect(function(char)
                 char:WaitForChild("Humanoid", 4)
                 wait(0.1)
                 onChar(char)
             end)
             table.insert(getgenv()._HBEConnections, charConn)
             if player.Character then
                 onChar(player.Character)
             end
         end

         local function updateHitboxes()
             for _, player in ipairs(Players:GetPlayers()) do
                 if isEnemy(player) and player.Character then
                     for _, root in ipairs(getRootParts(player.Character)) do
                         pcall(function()
                             if getgenv().HBE then
                                 root.Size = HITBOX_SIZE
                                 root.Color = HITBOX_COLOUR
                                 root.CanCollide = false
                                 root.Transparency = 0.5
                             else
                                 root.Size = Vector3.new(2,2,1)
                                 root.Transparency = 1
                             end
                         end)
                     end
                 end
             end
         end

         -- Enable Hitbox Expander
         getgenv().HBE = true

         if getgenv()._HBEUpdateConn then
             getgenv()._HBEUpdateConn:Disconnect()
         end
         getgenv()._HBEUpdateConn = game:GetService("RunService").RenderStepped:Connect(function()
             if getgenv().HBE then
                 updateHitboxes()
             end
         end)

         for _, player in ipairs(Players:GetPlayers()) do
             expandHitbox(player)
         end
         local playerConn = Players.PlayerAdded:Connect(expandHitbox)
         table.insert(getgenv()._HBEConnections, playerConn)

         -- Cleanup function (call this to disable and reset hitboxes)
         getgenv()._HBECleanup = function()
             getgenv().HBE = false
             if getgenv()._HBEUpdateConn then
                 getgenv()._HBEUpdateConn:Disconnect()
                 getgenv()._HBEUpdateConn = nil
             end
             if getgenv()._HBEConnections then
                 for _, conn in ipairs(getgenv()._HBEConnections) do
                     pcall(function() conn:Disconnect() end)
                 end
                 getgenv()._HBEConnections = {}
             end
             for _, player in ipairs(Players:GetPlayers()) do
                 if player.Character then
                     for _, root in ipairs(getRootParts(player.Character)) do
                         pcall(function()
                             root.Size = Vector3.new(2,2,1)
                             root.Transparency = 1
                         end)
                     end
                 end
             end
         end
      else
         -- Toggle OFF: Cleanup all hitbox connections and reset hitboxes
         if getgenv()._HBECleanup then
            getgenv()._HBECleanup()
         end
      end
   end,
})

local VisualsTab = Window:CreateTab("Visuals 👁️", nil) -- Title, Image
local Section = VisualsTab:CreateSection("ESP")

-- Add ESP Toggle to Visuals tab (replaces the button)
local espToggle
espToggle = VisualsTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Callback = function(state)
      if state then
         -- ESP ON
         local Players = game:GetService("Players")
         local RunService = game:GetService("RunService")
         local camera = workspace.CurrentCamera
         local lplr = Players.LocalPlayer
         local headOff = Vector3.new(0, 0.5, 0)
         local legOff = Vector3.new(0, 3, 0)

         -- Store connections for cleanup
         if not getgenv()._ESPConnections then getgenv()._ESPConnections = {} end
         if not getgenv()._ESPBoxes then getgenv()._ESPBoxes = {} end

         local function setupESP(v)
            if v == lplr then return end

            local boxOutline = Drawing.new("Square")
            boxOutline.Visible = false
            boxOutline.Color = Color3.new(0,0,0)
            boxOutline.Thickness = 1
            boxOutline.Filled = false

            local box = Drawing.new("Square")
            box.Visible = false
            box.Color = Color3.new(1,1,1)
            box.Thickness = 1
            box.Filled = false

            table.insert(getgenv()._ESPBoxes, box)
            table.insert(getgenv()._ESPBoxes, boxOutline)

            local function updateBoxColor()
               if v.TeamColor == lplr.TeamColor then
                  box.Color = Color3.new(0, 1, 0)
               else
                  box.Color = Color3.new(1, 0, 0)
               end
            end

            local teamConn1 = v:GetPropertyChangedSignal("TeamColor"):Connect(updateBoxColor)
            local teamConn2 = lplr:GetPropertyChangedSignal("TeamColor"):Connect(updateBoxColor)

            local renderConn
            renderConn = RunService.RenderStepped:Connect(function()
               if not v.Parent then
                  box:Remove()
                  boxOutline:Remove()
                  teamConn1:Disconnect()
                  teamConn2:Disconnect()
                  renderConn:Disconnect()
                  return
               end
               if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and v ~= lplr and v.Character.Humanoid.Health > 0 then
                  local rootPart = v.Character.HumanoidRootPart
                  local head = v.Character.Head
                  local rootPosition, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                  local headPosition = camera:WorldToViewportPoint(head.Position + headOff)
                  local legPosition = camera:WorldToViewportPoint(rootPart.Position - legOff)

                  if onScreen then
                     local size = Vector2.new(1000 / rootPosition.Z, headPosition.Y - legPosition.Y)
                     local pos = Vector2.new(rootPosition.X - size.X / 2, rootPosition.Y - size.Y / 2)

                     boxOutline.Size = size
                     boxOutline.Position = pos
                     boxOutline.Visible = true

                     updateBoxColor()
                     box.Size = size
                     box.Position = pos
                     box.Visible = true
                  else
                     boxOutline.Visible = false
                     box.Visible = false
                  end
               else
                  boxOutline.Visible = false
                  box.Visible = false
               end
            end)
            table.insert(getgenv()._ESPConnections, renderConn)
            table.insert(getgenv()._ESPConnections, teamConn1)
            table.insert(getgenv()._ESPConnections, teamConn2)
         end

         -- Setup ESP for all current players
         for _, v in ipairs(Players:GetPlayers()) do
            setupESP(v)
         end

         -- Setup ESP for new players
         local playerAddedConn = Players.PlayerAdded:Connect(setupESP)
         table.insert(getgenv()._ESPConnections, playerAddedConn)
      else
         -- ESP OFF: Cleanup all ESP drawings and connections
         if getgenv()._ESPConnections then
            for _, conn in ipairs(getgenv()._ESPConnections) do
               pcall(function() conn:Disconnect() end)
            end
            getgenv()._ESPConnections = {}
         end
         if getgenv()._ESPBoxes then
            for _, box in ipairs(getgenv()._ESPBoxes) do
               pcall(function() box:Remove() end)
            end
            getgenv()._ESPBoxes = {}
         end
      end
   end,
})
