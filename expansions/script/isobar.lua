-- Shared weather-state helpers for Isobar cards.
-- Weather is attached to the face-up Field Spell, not a duel-wide game rule.
ISOBAR=ISOBAR or {}
ISOBAR.SET=0x1df1
ISOBAR.FIELD=210000210
ISOBAR.FLAG=210009210
ISOBAR.EVENT=EVENT_CUSTOM+210000210
ISOBAR.SUN=1
ISOBAR.RAIN=2
ISOBAR.STORM=3
function ISOBAR.Field(tp)
 local c=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
 if c and c:IsFaceup() and c:IsCode(ISOBAR.FIELD) then return c end
 return nil
end
function ISOBAR.State(tp)
 local c=ISOBAR.Field(tp)
 if not c then return 0 end
 return c:GetFlagEffectLabel(ISOBAR.FLAG) or 0
end
function ISOBAR.Is(tp,state) return ISOBAR.State(tp)==state end
function ISOBAR.Change(tp,state,e)
 local c=ISOBAR.Field(tp)
 if not c or state<1 or state>3 then return false end
 local old=c:GetFlagEffectLabel(ISOBAR.FLAG) or 0
 if old==state then return false end
 c:ResetFlagEffect(ISOBAR.FLAG)
 c:RegisterFlagEffect(ISOBAR.FLAG,RESET_EVENT+RESETS_STANDARD,0,1,state)
 if old>0 then
  Duel.RaiseEvent(c,ISOBAR.EVENT,e,0,tp,tp,state)
 end
 return true
end
function ISOBAR.Choose(tp,exclude)
 local options={}
 for w=1,3 do if w~=exclude then options[#options+1]=w end end
 if #options==0 then return 0 end
 local hints={}
 for _,w in ipairs(options) do hints[#hints+1]=aux.Stringid(ISOBAR.FIELD,w-1) end
 local index=Duel.SelectOption(tp,table.unpack(hints))
 return options[index+1]
end
function ISOBAR.Monster(c)
 return c:IsSetCard(ISOBAR.SET) and c:IsMonster()
end
function ISOBAR.Xyz(c)
 return c:IsFaceup() and c:IsSetCard(ISOBAR.SET) and c:IsType(TYPE_XYZ)
end
