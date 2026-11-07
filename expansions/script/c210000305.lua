-- 오션 테일 - 고대왕 고래 바르카
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
 e1:SetTarget(s.lvtg)
 e1:SetOperation(s.lvop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_FIELD)
 e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
 e2:SetRange(LOCATION_MZONE)
 e2:SetTargetRange(LOCATION_MZONE,0)
 e2:SetTarget(ot.whale)
 e2:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
 c:RegisterEffect(e2)
 local e2b=e2:Clone();e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET);e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE);c:RegisterEffect(e2b)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(s.atkcon)
 e3:SetOperation(s.atkop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
s.listed_names={ot.LEVIATHAN}
function s.lvfilter(c,e,tp)
 return c:IsCode(ot.LEVIATHAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and ot.levirule(tp)
  and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.lvop(e,tp)
 if not ot.levirule(tp) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
 ot.summon(tp,function(c) return s.lvfilter(c,e,tp) end,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,POS_FACEUP_ATTACK,true)
end
function s.atkcon(e,tp)
 local c=e:GetHandler();local a=Duel.GetAttacker();local d=Duel.GetAttackTarget()
 return c:IsFaceup() and ((a==c and d and d:IsCode(ot.LEVIATHAN)) or
  (d==c and a and a:IsCode(ot.LEVIATHAN)))
end
function s.atkop(e,tp)
 local c=e:GetHandler();if not c:IsFaceup() then return end
 local e1=Effect.CreateEffect(c);e1:SetType(EFFECT_TYPE_SINGLE);e1:SetCode(EFFECT_UPDATE_ATTACK)
 e1:SetValue(1000);e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE);c:RegisterEffect(e1)
end
