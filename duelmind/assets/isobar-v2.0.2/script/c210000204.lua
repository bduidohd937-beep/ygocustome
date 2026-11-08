Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(EVENT_SUMMON_SUCCESS); e1:SetCountLimit(1,id); e1:SetCategory(CATEGORY_TOGRAVE); e1:SetTarget(s.tgtg); e1:SetOperation(s.tgop); c:RegisterEffect(e1); local e2=e1:Clone(); e2:SetCode(EVENT_SPSUMMON_SUCCESS); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e3:SetProperty(EFFECT_FLAG_DELAY); e3:SetCode(EVENT_TO_GRAVE); e3:SetCountLimit(1,id+1000); e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY) end); e3:SetTarget(s.tdtg); e3:SetOperation(s.tdop); c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.tgfilter(c) return ISOBAR.Monster(c) and c:IsAbleToGrave() end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end; Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK) end
function s.tgop(e,tp) local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end end
function s.tdfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsAbleToDeck() end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end; Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE) end
function s.tdop(e,tp) local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil); if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT); if ISOBAR.Is(tp,ISOBAR.SUN) then Duel.Draw(tp,1,REASON_EFFECT) end end end
