-- 오션 테일 - 소녀 마리나
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
 e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetTarget(s.stg)
 e1:SetOperation(s.sop)
 c:RegisterEffect(e1)
 local e1b=e1:Clone();e1b:SetCode(EVENT_SPSUMMON_SUCCESS);c:RegisterEffect(e1b)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_FIELD)
 e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
 e2:SetRange(LOCATION_MZONE)
 e2:SetTargetRange(LOCATION_MZONE,0)
 e2:SetTarget(ot.whale)
 e2:SetValue(1)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetDescription(aux.Stringid(id,2))
 e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
 e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
 e3:SetProperty(EFFECT_FLAG_DELAY)
 e3:SetCode(EVENT_RELEASE)
 e3:SetCountLimit(1,{id,3})
 e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_RITUAL) end)
 e3:SetTarget(s.mtg)
 e3:SetOperation(s.mop)
 c:RegisterEffect(e3)
end
s.listed_series={ot.SET}
function s.stf(c) return ot.spell(c) and c:IsAbleToHand() end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.stf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sop(e,tp) ot.search(tp,s.stf) end
function s.mtf(c) return ot.monster(c) and c:IsAbleToHand() end
function s.mtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.mtf,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.mop(e,tp) ot.search(tp,s.mtf) end
