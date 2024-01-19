hook.Add("StarGate.Bullet", "StarGate.ShieldCore.Bullet", function(self, bullet, trace)
    local e = trace.Entity

    -- Check if the hit entity is a "shield_core_buble" and is valid
    if IsValid(e) and e:GetClass() == "shield_core_buble" then
        -- Call the callback (e.g., to draw effects like bullet tracers)
        if bullet.Callback then
            local dmg = DamageInfo()
            dmg:SetDamage(bullet.Damage or 0)
            bullet.Callback(self, trace, dmg)
        end

        if SERVER then
            -- Draw a bullet tracer into the Shield
            if bullet.Tracer and bullet.Tracer ~= 0 then
                local fx = EffectData()
                fx:SetStart(bullet.Src)
                fx:SetOrigin(trace.HitPos)
                fx:SetScale(5000)
                fx:SetNormal(trace.HitNormal)
                util.Effect(bullet.TracerName or "Tracer", fx, true, true)
            end

            -- Ensure that the shield entity handles the bullet hit
            e:Hit(self, trace.HitPos, (bullet.Damage or 20) / 20, -1 * trace.Normal)
        end

        -- Return true to indicate that the custom bullet handling overrides the original behavior
        return true
    end
end)
