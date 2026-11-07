Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e1:SetProperty(EFFECT_FLAG_DELAY); e1:SetCode(EVENT_SUMMON_SUCCESS); e1:SetCountLimit(1,id); e1:SetCategory(CATEGORY_SPECIAL_SUMMON); e1:SetTarget(s.sptg); e1:SetOperation(s.spop); c:RegisterEffect(e1); local e2=e1:Clone(); e2:SetCode(EVENT_SPSUMMON_SUCCESS); c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c); e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O); e3:SetProperty(EFFECT_FLAG_DELAY); e3:SetCode(EVENT_TO_GRAVE); e3:SetCountLimit(1,id+1000); e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY) end); e3:SetTarget(s.tgtg); e3:SetOperation(s.tgop); c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.filter(c,e,tp) return ISOBAR.Monster(c) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end; Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE) end
function s.spop(e,tp) local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp); if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then for tc in aux.Next(g) do local a=Effect.CreateEffect(e:GetHandler()); a:SetType(EFFECT_TYPE_SINGLE); a:SetCode(EFFECT_DISABLE); a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END); tc:RegisterEffect(a); local b=a:Clone(); b:SetCode(EFFECT_DISABLE_EFFECT); tc:RegisterEffect(b) end end end
function s.tfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsAbleToDeck() end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end end
function s.tgop(e,tp) local g=Duel.SelectMatchingCard(tp,s.tfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler()); if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end end
