--################# This is the workaround for stopping bullets (FROM SWEPS AND SENTS ONLY!) getting into a shield @aVoN
hook.Add("StarGate.Bullet", "StarGate.ShieldCore.Bullet", function(self, bullet, trace)
    local e = trace.Entity;

    if IsValid(e) and (e:GetClass() == "shield_core_buble" or e:GetClass() == "rpg_missile") then
        -- Call the callback (e.g., to draw effects like bullet tracers!)
        if bullet.Callback then
            local dmg = DamageInfo()
            dmg:SetDamage(bullet.Damage or 0)
            bullet.Callback(self, trace, dmg)
        end

        if SERVER then
            -- Draw a bullet tracer into the Shield
            if bullet.Tracer ~= 0 then
                local fx = EffectData()
                fx:SetStart(bullet.Src)
                fx:SetOrigin(trace.HitPos)
                fx:SetScale(5000)
                fx:SetNormal(trace.HitNormal)
                util.Effect(bullet.TracerName or "Tracer", fx, true, true)
            end

            e:Hit(self, trace.HitPos, (bullet.Damage or 20) / 20, -1 * trace.Normal)
        end

        return true -- Tell we override the original bullet!
    end
end)
