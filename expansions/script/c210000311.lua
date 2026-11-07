-- 오션 테일 - 잔잔한 파도
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.tg)
 e1:SetOperation(s.op)
 c:RegisterEffect(e1)
end
s.listed_series={ot.SET}
function s.f(c,e,tp) return ot.lower(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.f,tp,LOCATION_DECK,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp)
 local g=Duel.SelectMatchingCard(tp,function(c) return s.f(c,e,tp) end,tp,LOCATION_DECK,0,1,1,nil)
 if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
