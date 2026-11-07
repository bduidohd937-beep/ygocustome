-- Isobar Spell/Trap: 210000212
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
s.listed_series={ISOBAR.SET}
function s.thfilter(c) return ISOBAR.Monster(c) and c:IsAbleToHand() end
function s.sendfilter(c) return c:IsSetCard(ISOBAR.SET) and c:IsAbleToGrave() end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
 if #g==0 then return end
 Duel.SendtoHand(g,nil,REASON_EFFECT)
 Duel.ConfirmCards(1-tp,g)
 if Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local sg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND,0,1,1,nil)
  if #sg>0 then Duel.SendtoGrave(sg,REASON_EFFECT) end
 end
end
