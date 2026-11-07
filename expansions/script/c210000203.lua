-- Isobar: 210000203
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCountLimit(1,id)
 e1:SetTarget(s.lvtg)
 e1:SetOperation(s.lvop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,id+1000)
 e2:SetTarget(s.atktg)
 e2:SetOperation(s.atkop)
 c:RegisterEffect(e2)
end
s.listed_series={ISOBAR.SET}
function s.lvfilter(c,sc)
 return c~=sc and c:IsFaceup() and ISOBAR.Monster(c) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,e:GetHandler()) end
 if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler()) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
 Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e:GetHandler())
end
function s.setlevel(c,source)
 local e1=Effect.CreateEffect(source)
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(EFFECT_CHANGE_LEVEL)
 e1:SetValue(4)
 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 c:RegisterEffect(e1)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 local tc=Duel.GetFirstTarget()
 if c:IsFaceup() then s.setlevel(c,c) end
 if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then s.setlevel(tc,c) end
end
function s.atkfilter(c) return c:IsFaceup() and c:IsAttackAbove(1) end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
 if chk==0 then return ISOBAR.Is(tp,ISOBAR.STORM) and Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
 Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
 local tc=Duel.GetFirstTarget()
 if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(-800)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
 end
end
