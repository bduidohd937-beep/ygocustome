Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_IGNITION); e1:SetRange(LOCATION_HAND); e1:SetCountLimit(1,id); e1:SetCategory(CATEGORY_SPECIAL_SUMMON); e1:SetTarget(s.sptg); e1:SetOperation(s.spop); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e2:SetProperty(EFFECT_FLAG_DELAY); e2:SetCode(EVENT_SUMMON_SUCCESS); e2:SetCountLimit(1,id+1000); e2:SetCondition(s.thcon); e2:SetTarget(s.thtg); e2:SetOperation(s.thop); c:RegisterEffect(e2); local e3=e2:Clone(); e3:SetCode(EVENT_SPSUMMON_SUCCESS); c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return (ISOBAR.Field(tp)~=nil or Duel.IsExistingMatchingCard(ISOBAR.Monster,tp,LOCATION_MZONE,0,1,nil)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end end
function s.spop(e,tp) Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP) end
function s.thcon(e,tp) return ISOBAR.Is(tp,ISOBAR.RAIN) end
function s.thfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end; Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE) end
function s.thop(e,tp) local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end end
