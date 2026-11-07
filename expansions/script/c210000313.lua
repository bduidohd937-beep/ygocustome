-- 오션 테일 - 결전의 장
Duel.LoadScript("ocean_tale_v41.lua")
local ot=OceanTaleV41
local s,id=GetID()
function s.initial_effect(c)
 local e0=Effect.CreateEffect(c)
 e0:SetDescription(aux.Stringid(id,0))
 e0:SetType(EFFECT_TYPE_ACTIVATE)
 e0:SetCode(EVENT_FREE_CHAIN)
 e0:SetCountLimit(1,id)
 e0:SetTarget(s.settg)
 e0:SetOperation(s.setop)
 c:RegisterEffect(e0)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,1))
 e1:SetType(EFFECT_TYPE_FIELD)
 e1:SetCode(EFFECT_UPDATE_ATTACK)
 e1:SetRange(LOCATION_FZONE)
 e1:SetTargetRange(LOCATION_MZONE,0)
 e1:SetCondition(s.levcon)
 e1:SetTarget(function(e,tc) return ot.monster(tc) end)
 e1:SetValue(600)
 c:RegisterEffect(e1)
 local e1b=Effect.CreateEffect(c)
 e1b:SetType(EFFECT_TYPE_FIELD)
 e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
 e1b:SetRange(LOCATION_FZONE)
 e1b:SetTargetRange(LOCATION_MZONE,0)
 e1b:SetCondition(s.levcon)
 e1b:SetTarget(function(e,tc) return ot.monster(tc) end)
 e1b:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
 c:RegisterEffect(e1b)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,2))
 e2:SetCategory(CATEGORY_DAMAGE)
 e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
 e2:SetCode(EVENT_TO_HAND)
 e2:SetRange(LOCATION_FZONE)
 e2:SetCondition(s.burncon)
 e2:SetOperation(function(e,tp) Duel.Damage(1-tp,500,REASON_EFFECT) end)
 c:RegisterEffect(e2)
end
s.listed_series={ot.SET}
s.listed_names={ot.LEVIATHAN}
function s.levcon(e,tp) return ot.opponentLevi(e:GetHandlerPlayer()) end
function s.setf(c) return ot.spell(c) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable() end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setf,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp)
 if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
 local g=Duel.SelectMatchingCard(tp,s.setf,tp,LOCATION_DECK,0,1,1,nil)
 local tc=g:GetFirst()
 if not tc or Duel.SSet(tp,tc)==0 then return end
 local e1=Effect.CreateEffect(e:GetHandler())
 e1:SetType(EFFECT_TYPE_SINGLE);e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
 e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE);e1:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(e1)
end
function s.burncon(e,tp,eg,ep,ev,re,r,rp)
 if not s.levcon(e,tp) or Duel.GetCurrentPhase()==PHASE_DRAW or ep~=1-tp then return false end
 return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_DECK) end,1,nil)
end
