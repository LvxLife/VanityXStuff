function Init()
    if #GhostRoom <= 0 then
        local elap = os.clock()
        local z = {false, false, false}
        local sv 
        sv = game:GetService('RunService').RenderStepped:connect(function()
            if tonumber(Step) < 3 then pcall(function() client.Character.Humanoid:ChangeState(11) end) end
            if tonumber(Step) == 3 then sv:Disconnect() end
            if IsReady == true then sv:Disconnect() end
        end)
        local HRoot
        repeat wait() HRoot = client.Character and (client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart') or client.Character:FindFirstChildWhichIsA('Basepart')) until HRoot
        local OldPlayerPosition = HRoot.CFrame
        Step = '1' --// 1: pickup, equip, 2: active tool and teleport to every room emf use wait(.5) or thermo wait(1.7)
        log('Please wait...')
        while (tonumber(Step) <= 3) and IsReady == false do
            if Step == '1' then
                local Tool = Items:FindFirstChild('EMF Reader') or client.Character:FindFirstChild('EMF Reader')
                if not Tool then 
                    sv:Disconnect()
                    IsReady = 'Fail'
                    return log('Failed to initializing ghost room... Please get the emf reader') 
                end
                if client.Character:IsAncestorOf(Tool) then Step = '1.6' end
                if Items:IsAncestorOf(Tool) then
                    local fire = fireproximityprompt or game:GetService('ReplicatedStorage'):FindFirstChild('Pickup')
                    repeat
                        pcall(function()
                            local Body = Tool.PrimaryPart or Tool:FindFirstChildWhichIsA('BasePart') or Tool:FindFirstChild('Hand')
                            local HRoot = client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart')
                            HRoot.CFrame = Body.CFrame + Vector3.new(0, 1, 0)
                        end)
                        wait(.2)
                        pcall(function()
                            if type(fire) == 'function' then
                                local proximity = Tool:FindFirstChild('Hand') and Tool.Hand:FindFirstChildOfClass('ProximityPrompt')
                                fire(proximity)
                            else    
                                fire:InvokeServer(Tool)
                            end
                        end)
                    until not Tool.Parent or client.Character:IsAncestorOf(Tool) or Step == 2
                    if Tool.Parent == nil and not Items:IsAncestorOf(Tool) or not client.Character:IsAncestorOf(Tool) then
                        Step = '1.5'
                    end
                end
            end
            wait()
            if Step == '1.5' then
                local Toolbar = client:FindFirstChild('PlayerGui') and (client.PlayerGui:FindFirstChild('ScreenGui') and client.PlayerGui.ScreenGui:FindFirstChild('Toolbar'))
                local Image = client:FindFirstChild('PlayerGui') and (client.PlayerGui:FindFirstChild('ItemImages') and client.PlayerGui.ItemImages:FindFirstChild('EMF Reader') and client.PlayerGui.ItemImages['EMF Reader'].Value)
                local Equip = game:GetService("ReplicatedStorage"):FindFirstChild('Equip')
                for _,v in pairs(Toolbar:GetChildren()) do
                    if v:IsA('ImageButton') and v.Name:match('Item%d') and v.Image == Image then
                        local Number = tonumber(v.Name:match('%d'))
                        Equip:InvokeServer(Number)
                        Step = '1.6'
                        break
                    end
                end
                wait(.1)
                if not client.Character:FindFirstChild('EMF Reader') then
                    for Index in pairs(z) do
                        if z[Index] == false then
                            Equip:InvokeServer(Index)
                            local c = client.Character:FindFirstChild('EMF Reader')
                            if c then
                                Step = '1.6'
                                break
                            end

                            z[Index] = true
                        end
                    end
                end
            end
            wait(.1)
            if Step == '1.6' then
                local Tool = client.Character:FindFirstChild('EMF Reader') or client.Character:WaitForChild('EMF Reader')
                log(Tool)
                if Tool then
                    local on = Tool:FindFirstChild('On') and (Tool['On'].Value == true)
                    function toggle() return game:GetService("ReplicatedStorage").ToggleTool:InvokeServer() end
                    if not on then
                        coroutine.wrap(toggle)()
                    end
                    repeat wait() 
                        on = Tool:FindFirstChild('On') and (Tool['On'].Value == true) 
                    until on == true
                    
                    Step = '2'
                end
            end
            wait(.2)
            if Step == '2' then
                local Tool = client.Character:FindFirstChild('EMF Reader') or client.Character:WaitForChild('EMF Reader')
                local h = {['EMF Reader'] = 0.5}
                game:GetService('ReplicatedStorage').Start:FireServer()
                for _,v in pairs(Rooms:GetChildren()) do
                    if v:IsA('Folder') and v:FindFirstChild('Hitbox') then
                        local Hitbox,RoomName = v.Hitbox,v.RoomName.Value
                        local HRoot = client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart')
                        HRoot.CFrame = Hitbox.CFrame * CFrame.new(1.5, -1, 0)
                        wait(h[tostring(Tool)])
                        local mhm = (Tool:FindFirstChild('L1') and Tool:FindFirstChild('L2')) and (Tool.L1.BrickColor ~= BrickColor.new('Smoky grey') and Tool.L2.BrickColor ~= BrickColor.new('Smoky grey'))
                        local mhm2 = not mhm and (Tool:FindFirstChild('Temp') and Tool.Temp.SurfaceGui.Frame.TextLabel.Text) and tonumber(Tool.Temp.SurfaceGui.Frame.TextLabel.Text:match('(%d+.%d+)') < 7)
                        if mhm or mhm2 then
                            table.insert(GhostRoom, Hitbox)
                            table.insert(GhostRoom, RoomName)
                            --game:GetService("ReplicatedStorage").Drop:InvokeServer()
                            IsReady = true
                            Step = '3'
                            break
                        end
                    end
                end
                repeat wait() until IsReady or Step == '3' or Step == '2'
                if Step == '2' then
                    game:GetService('ReplicatedStorage').Start:FireServer()
                    Step = '2'
                end
            end

            if Step == '3' then
                HRoot.CFrame = OldPlayerPosition
                return log(('Initializing is done! All code executed in %0.2fs'):format(os.clock() - elap))
            end
        end
    end
end
return Init
