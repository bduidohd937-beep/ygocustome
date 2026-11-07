Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e=Effect.CreateEffect(c); e:SetType(EFFECT_TYPE_ACTIVATE); e:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH); e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON); e:SetTarget(s.tg); e:SetOperation(s.op); c:RegisterEffect(e)
end
s.listed_series={ISOBAR.SET}
function s.f(c) return ISOBAR.Monster(c) and c:IsAbleToHand() end
function s.g(c) return c:IsSetCard(ISOBAR.SET) and c:IsAbleToGrave() end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.f,tp,LOCATION_DECK,0,1,nil) end end
function s.op(e,tp) local g=Duel.SelectMatchingCard(tp,s.f,tp,LOCATION_DECK,0,1,1,nil); if #g==0 then return end; Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g); if Duel.IsExistingMatchingCard(s.g,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then local sg=Duel.SelectMatchingCard(tp,s.g,tp,LOCATION_HAND,0,1,1,nil); if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then local rg=Duel.SelectMatchingCard(tp,function(c) return ISOBAR.Monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_GRAVE,0,1,1,nil); if #rg>0 then Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP); local x=rg:GetFirst(); local a=Effect.CreateEffect(e:GetHandler()); a:SetType(EFFECT_TYPE_SINGLE); a:SetCode(EFFECT_DISABLE); a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END); x:RegisterEffect(a); local b=a:Clone(); b:SetCode(EFFECT_DISABLE_EFFECT); x:RegisterEffect(b); local d=a:Clone(); d:SetCode(EFFECT_LEAVE_FIELD_REDIRECT); d:SetProperty(EFFECT_FLAG_CANNOT_DISABLE); d:SetReset(RESET_EVENT+RESETS_REDIRECT); d:SetValue(LOCATION_REMOVED); x:RegisterEffect(d,true) end end end end end
