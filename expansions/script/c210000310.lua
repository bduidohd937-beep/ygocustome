-- 오션 테일 - 보물 탐색
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.tg)
 e1:SetOperation(s.op)
 c:RegisterEffect(e1)
end
s.listed_series={ot.SET}
function s.f(c) return ot.archetype(c) and (c:IsMonster() or c:IsSpell()) and c:IsAbleToHand() end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.f,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp) ot.search(tp,s.f) end
