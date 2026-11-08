Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(EVENT_SUMMON_SUCCESS); e1:SetCountLimit(1,id); e1:SetTarget(s.thtg); e1:SetOperation(s.thop); c:RegisterEffect(e1)
 local e2=e1:Clone(); e2:SetCode(EVENT_SPSUMMON_SUCCESS); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O); e3:SetProperty(EFFECT_FLAG_DELAY); e3:SetCode(ISOBAR.EVENT); e3:SetRange(LOCATION_HAND+LOCATION_GRAVE); e3:SetCountLimit(1,id+1000); e3:SetCondition(function(e,tp) return ISOBAR.Field(tp)~=nil end); e3:SetTarget(s.sptg); e3:SetOperation(s.spop); c:RegisterEffect(e3)
end
s.listed_names={210000210}; s.listed_series={ISOBAR.SET}
function s.thfilter(c) return c:IsCode(210000210) or (c:IsSpellTrap() and c:IsSetCard(ISOBAR.SET)) end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end end
function s.thop(e,tp) local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end; Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,e:GetHandler():IsLocation(LOCATION_HAND) and LOCATION_HAND or LOCATION_GRAVE) end
function s.spop(e,tp) local c=e:GetHandler(); if c:IsRelateToEffect(e) then local fromgrave=c:IsLocation(LOCATION_GRAVE); if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and fromgrave then local x=Effect.CreateEffect(c); x:SetType(EFFECT_TYPE_SINGLE); x:SetCode(EFFECT_LEAVE_FIELD_REDIRECT); x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE); x:SetReset(RESET_EVENT+RESETS_REDIRECT); x:SetValue(LOCATION_REMOVED); c:RegisterEffect(x,true) end end end
