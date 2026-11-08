Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_IGNITION); e1:SetRange(LOCATION_HAND); e1:SetCountLimit(1,id); e1:SetCategory(CATEGORY_SPECIAL_SUMMON); e1:SetTarget(s.sptg); e1:SetOperation(s.spop); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_QUICK_O); e2:SetCode(EVENT_FREE_CHAIN); e2:SetRange(LOCATION_MZONE); e2:SetCountLimit(1,id+1000); e2:SetCondition(function(e) return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 end); e2:SetTarget(s.wxtg); e2:SetOperation(s.wxop); c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return Duel.IsExistingMatchingCard(ISOBAR.Monster,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end end
function s.spop(e,tp) Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP) end
function s.wxtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.Field(tp)~=nil and ISOBAR.State(tp)>0 end end
function s.wxop(e,tp) ISOBAR.Change(tp,ISOBAR.Choose(tp,ISOBAR.State(tp)),e); ISOBAR.ApplyMachineLock(e:GetHandler(),tp) end
