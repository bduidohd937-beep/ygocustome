Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c); e1:SetType(EFFECT_TYPE_QUICK_O); e1:SetCode(EVENT_FREE_CHAIN); e1:SetCountLimit(1,id); e1:SetTarget(s.tg); e1:SetOperation(s.op); c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c); e2:SetType(EFFECT_TYPE_IGNITION); e2:SetRange(LOCATION_GRAVE); e2:SetCountLimit(1,id+1000); e2:SetCost(aux.bfgcost); e2:SetTarget(s.gtg); e2:SetOperation(s.gop); c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return ISOBAR.Field(tp)~=nil and not ISOBAR.Is(tp,ISOBAR.STORM) and Duel.IsExistingTarget(function(c) return c:IsSpellTrap() and c:IsAbleToHand() end,tp,0,LOCATION_ONFIELD,1,nil) end; Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD) end
function s.op(e,tp) if not ISOBAR.Change(tp,ISOBAR.STORM,e) then return end; local g=Duel.SelectMatchingCard(tp,function(c) return c:IsSpellTrap() and c:IsAbleToHand() end,tp,0,LOCATION_ONFIELD,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingTarget(function(c) return ISOBAR.Monster(c) and c:IsAbleToDeck() end,tp,LOCATION_GRAVE,0,1,nil) end end
function s.gop(e,tp) local g=Duel.SelectMatchingCard(tp,function(c) return ISOBAR.Monster(c) and c:IsAbleToDeck() end,tp,LOCATION_GRAVE,0,1,1,nil); if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then Duel.Draw(tp,1,REASON_EFFECT) end end
