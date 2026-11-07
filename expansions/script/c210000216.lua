Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetCategory(CATEGORY_TOHAND)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.acttg)
 e1:SetOperation(s.actop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_GRAVE)
 e2:SetCountLimit(1,id+1000)
 e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id+3000)==0 end)
 e2:SetCost(aux.bfgcost)
 e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetTarget(s.gtg)
 e2:SetOperation(s.gop)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e3:SetProperty(EFFECT_FLAG_DELAY)
 e3:SetCode(EVENT_TO_GRAVE)
 e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA) end)
 e3:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id+3000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1) end)
 c:RegisterEffect(e3)
end
s.listed_series={ISOBAR.SET}
function s.stfilter(c)
 return c:IsSpellTrap() and c:IsAbleToHand()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.stfilter(chkc) end
 if chk==0 then
  return ISOBAR.Field(tp)~=nil and not ISOBAR.Is(tp,ISOBAR.STORM)
   and Duel.IsExistingMatchingCard(ISOBAR.Monster,tp,LOCATION_MZONE,0,1,nil)
   and Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_ONFIELD,1,nil)
 end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
 local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,1-tp,LOCATION_ONFIELD)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
 if not ISOBAR.Change(tp,ISOBAR.STORM,e) then return end
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
function s.gfilter(c)
 return ISOBAR.Monster(c) and c:IsAbleToDeck()
end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gfilter(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,LOCATION_GRAVE,0,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
 local g=Duel.SelectTarget(tp,s.gfilter,tp,LOCATION_GRAVE,0,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_GRAVE)
 Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then Duel.Draw(tp,1,REASON_EFFECT) end
end
