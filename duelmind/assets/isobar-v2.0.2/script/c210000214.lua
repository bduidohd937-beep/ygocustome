Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_IGNITION); e1:SetRange(LOCATION_HAND); e1:SetCountLimit(1,id); e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or ISOBAR.Field(tp)~=nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end end); e1:SetOperation(function(e,tp) Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP) end); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e2:SetProperty(EFFECT_FLAG_DELAY); e2:SetCode(EVENT_SUMMON_SUCCESS); e2:SetCountLimit(1,id+1000); e2:SetTarget(s.tg); e2:SetOperation(s.op); c:RegisterEffect(e2); local e3=e2:Clone(); e3:SetCode(EVENT_SPSUMMON_SUCCESS); c:RegisterEffect(e3)
end
s.listed_names={210000210}; s.listed_series={ISOBAR.SET}
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsCode(210000210) and c:IsAbleToHand() end,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(function(c) return ISOBAR.Monster(c) and not c:IsCode(id) and c:IsAbleToHand() end,tp,LOCATION_DECK,0,1,nil) end end
function s.op(e,tp) local f=ISOBAR.Field(tp); local q=function(c) return ISOBAR.Monster(c) and not c:IsCode(id) and c:IsAbleToHand() end; local g; if f then g=Duel.SelectMatchingCard(tp,q,tp,LOCATION_DECK,0,1,1,nil) else g=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(210000210) and c:IsAbleToHand() end,tp,LOCATION_DECK,0,1,1,nil) end; if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end end
