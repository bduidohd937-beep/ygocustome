-- Deathfire Volt V2: 210000107
local s,id=GetID()
local COUNTER=0x1099
function s.initial_effect(c)
 c:EnableCounterPermit(COUNTER)
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetCategory(CATEGORY_COUNTER)
 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
 e2:SetCode(EVENT_DAMAGE)
 e2:SetRange(LOCATION_SZONE)
 e2:SetCondition(s.ctcon)
 e2:SetOperation(s.ctop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
 e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
 e3:SetRange(LOCATION_SZONE)
 e3:SetTargetRange(LOCATION_MZONE,0)
 e3:SetCondition(s.protcon)
 e3:SetTarget(s.prottg)
 e3:SetValue(aux.tgoval)
 c:RegisterEffect(e3)
end
s.mentioned_counter={[COUNTER]=true}
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
 return ep==1-tp and (r&REASON_EFFECT)~=0
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 if c:IsFaceup() then c:AddCounter(COUNTER,1) end
end
function s.ctfilter(c) return c:GetCounter(COUNTER)>0 end
function s.protcon(e)
 local tp=e:GetHandlerPlayer()
 return Duel.GetCounter(tp,1,0,COUNTER)>=5
end
function s.prottg(e,c) return c:IsRace(RACE_THUNDER) end
