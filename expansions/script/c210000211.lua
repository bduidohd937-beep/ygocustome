-- Isobar Spell/Trap: 210000211
Duel.LoadScript("isobar.lua")
local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
s.listed_series={ISOBAR.SET}
s.listed_names={210000210}
function s.filter(c) return c:IsFaceup() and ISOBAR.Monster(c) end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return ISOBAR.State(tp)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local old=ISOBAR.State(tp)
 if old==0 then return end
 ISOBAR.Change(tp,ISOBAR.Choose(tp,old),e)
 local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
 if #g==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local tc=g:Select(tp,1,1,nil):GetFirst()
 if not tc then return end
 local choice=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetCode(choice==0 and EFFECT_UPDATE_ATTACK or EFFECT_UPDATE_DEFENSE)
 e1:SetValue(500)
 e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
 tc:RegisterEffect(e1)
end
