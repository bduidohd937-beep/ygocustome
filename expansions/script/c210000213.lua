-- Isobar Spell/Trap: 210000213
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DISABLE)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
s.listed_series={ISOBAR.SET}
function s.xyz(c) return ISOBAR.Xyz(c) end
function s.filter(c) return c:IsFaceup() end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.filter(chkc) end
 if chk==0 then return Duel.IsExistingMatchingCard(s.xyz,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
 Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(EFFECT_DISABLE)
 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 tc:RegisterEffect(e1)
 local e2=e1:Clone()
 e2:SetCode(EFFECT_DISABLE_EFFECT)
 tc:RegisterEffect(e2)
 if tc:IsMonster() and ISOBAR.Is(tp,ISOBAR.STORM) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
  local e3=Effect.CreateEffect(e:GetHandler())
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_SET_ATTACK_FINAL)
  e3:SetValue(0)
  e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e3)
 end
end
