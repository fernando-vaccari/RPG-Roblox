local controller=require(script.Parent.EnemyAnimationClient).start()
script.Destroying:Connect(function()controller:destroy()end)
