-- Ocean Tale V4.1 shared helpers; EDOPro Lua 5.3
OceanTaleV41=OceanTaleV41 or {}
local ot=OceanTaleV41

ot.SET=0x1df2
ot.MARINA=210000301
ot.MARIN=210000302
ot.BELU=210000303
ot.LEVIATHAN=210000304
ot.BARKA=210000305
ot.ARCA=210000306
ot.LINK1=210000307
ot.LINK2=210000308

function ot.archetype(c) return c:IsSetCard(ot.SET) end
function ot.monster(c) return ot.archetype(c) and c:IsMonster() end
function ot.spell(c) return ot.archetype(c) and c:IsSpell() end
function ot.lv5(c) return ot.monster(c) and c:IsLevelAbove(5) end
function ot.lower(c) return ot.monster(c) and c:IsLevelBelow(5) end
function ot.levi(c) return c:IsCode(ot.LEVIATHAN) end
function ot.leviFaceup(c) return c:IsFaceup() and ot.levi(c) end
function ot.anyLevi(tp)
 return Duel.IsExistingMatchingCard(ot.leviFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function ot.opponentLevi(tp)
 return Duel.IsExistingMatchingCard(ot.leviFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function ot.levirule(tp) return not ot.anyLevi(tp) end
function ot.search(tp,filter,location)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,filter,tp,location or LOCATION_DECK,0,1,1,nil)
 if #g>0 then
  Duel.SendtoHand(g,nil,REASON_EFFECT)
  Duel.ConfirmCards(1-tp,g)
 end
 return g
end
function ot.recover(tp,filter,location)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,filter,tp,location or (LOCATION_GRAVE|LOCATION_REMOVED),0,1,1,nil)
 if #g>0 then
  Duel.SendtoHand(g,nil,REASON_EFFECT)
  Duel.ConfirmCards(1-tp,g)
 end
 return g
end
function ot.summon(tp,filter,location,position,toOpponent)
 local p=toOpponent and 1-tp or tp
 if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return false end
 local g=Duel.SelectMatchingCard(tp,filter,tp,location,0,1,1,nil)
 local tc=g:GetFirst()
 if not tc then return false end
 return Duel.SpecialSummon(tc,0,tp,p,false,false,position or POS_FACEUP)>0
end
function ot.whale(c)
 return c:IsFaceup() and c:IsMonster() and c:IsCode(ot.BELU,ot.BARKA,ot.ARCA)
end
function ot.ritual(c) return ot.monster(c) and c:IsType(TYPE_RITUAL) end
function ot.immune(e,te)
 return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
function ot.tempReturn(e,tp)
 local tc=e:GetLabelObject()
 if not tc or not tc:IsLocation(LOCATION_REMOVED) then return end
 if tc:IsPreviousLocation(LOCATION_HAND) then
  Duel.SendtoHand(tc,nil,REASON_EFFECT)
 elseif tc:IsPreviousLocation(LOCATION_GRAVE) then
  Duel.SendtoGrave(tc,REASON_EFFECT)
 elseif tc:IsPreviousLocation(LOCATION_ONFIELD) then
  Duel.ReturnToField(tc)
 end
end
function ot.registerTempReturn(tc,tp,returnop)
 local e=Effect.CreateEffect(tc)
 e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
 e:SetCode(EVENT_PHASE|PHASE_END)
 e:SetReset(RESET_PHASE|PHASE_END)
 e:SetLabelObject(tc)
 e:SetOperation(returnop or ot.tempReturn)
 Duel.RegisterEffect(e,tp)
end
