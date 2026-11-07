Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e=Effect.CreateEffect(c); e:SetType(EFFECT_TYPE_ACTIVATE); e:SetProperty(EFFECT_FLAG_CARD_TARGET); e:SetCode(EVENT_FREE_CHAIN); e:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH); e:SetTarget(s.tg); e:SetOperation(s.op); c:RegisterEffect(e)
end
s.listed_series={ISOBAR.SET}
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() end; if chk==0 then return Duel.IsExistingMatchingCard(ISOBAR.Xyz,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end; Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil) end
function s.op(e,tp) local c=Duel.GetFirstTarget(); if not c or not c:IsRelateToEffect(e) then return end; local a=Effect.CreateEffect(e:GetHandler()); a:SetType(EFFECT_TYPE_SINGLE); a:SetCode(EFFECT_DISABLE); a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END); c:RegisterEffect(a); local b=a:Clone(); b:SetCode(EFFECT_DISABLE_EFFECT); c:RegisterEffect(b); if c:IsMonster() and ISOBAR.Is(tp,ISOBAR.STORM) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then local d=a:Clone(); d:SetCode(EFFECT_SET_ATTACK_FINAL); d:SetValue(0); c:RegisterEffect(d) end end
