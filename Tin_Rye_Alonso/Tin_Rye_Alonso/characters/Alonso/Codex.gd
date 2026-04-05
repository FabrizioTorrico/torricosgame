extends Node

const MJOUST = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/MinJoust.png"
const MDP = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/MinDP.png"
const MDIVE = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/MinDive.png"
const MPIN = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/Minthrow.png"
const MDETONATE = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/mindestruct.png"
const DOLLBUTTON = "res://Tin_Rye_Alonso/characters/Alonso/sprites/UI/Doll.png"
const ZIP = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/hook.png"
const PULL = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/Pulling.png"
const PUNCH = "res://Tin_Rye_Alonso/characters/Alonso/sprites/icons/bigpunch.png"

var text_block = ""

func register(codex):
	codex.set_subtitle("Playwright")
	
	text_block = "By: TinFoilMkIV & Ryedork \nPart of the Yomi Legends mod jam.\n\n"
	text_block += "Alonso commands a team of unpaid actors to create chaos upon the stage.\n\n"
	text_block += pic(DOLLBUTTON) +pic(DOLLBUTTON) +pic(DOLLBUTTON) +"\n"
	text_block += "Select the active performer via the performer buttons (shown above) for related commands.\n\n"
	text_block += "Performers can be hit by Alonso to be launched as projectiles. Their aim is affected by your DI. Performers only take damage from opponent attacks.\n\n"
	text_block += pic(ZIP) +pic(PULL) +pic(PUNCH) +"\n"
	text_block += "Alonso can tether to the opponent or one of his performers with certain moves. Alonso can pull himself towards the tethered character, or use special actions.\n"
		
	codex.set_summary(text_block)
	
	#============ Mechanics ============
#	text_block = pic(DOLLBUTTON) +pic(DOLLBUTTON) +pic(DOLLBUTTON) +" Dolls\n"
#	text_block += "Alonso may have up to three active dolls as supporting actors."
#
	#codex.add_custom_text_tab("Mechanics", text_block)
#	codex.add_custom_text_tab("Credits", text_block)

	#*********************************************************************************************************************
	#============ Move Descriptions ============
	#Jab ************************************************************************************************************
	var jab_desc = "Get stabby.\nIt's a jab..."
	codex.moveset["Jab"].desc = jab_desc
	#-********************************************************************************************************************
	#claw ************************************************************************************************************
	var claw_desc = "Good ol claw swipe. \nDecent range"
	codex.moveset["clawing"].desc = claw_desc
	#-********************************************************************************************************************
	#pratfall ************************************************************************************************************
	var crush_desc = "Swing big! \nDoes good damage right in front. Launches on the back."
	codex.moveset["crush"].desc = crush_desc
	#-********************************************************************************************************************
	#pratfall ************************************************************************************************************
	var skid_desc = "How low can you go? \nLow profile properties"
	codex.moveset["Skid"].desc = skid_desc
	#-********************************************************************************************************************
	#jumpclaw ************************************************************************************************************
	var jumpclaw_desc = "Make the jump and hit those high notes. \nStarts faster in the air"
	codex.moveset["JumpClaw"].desc = jumpclaw_desc
	#-********************************************************************************************************************
	#RisingSlash ************************************************************************************************************
	var rising_desc = "Rise like a true star! \nFront hits up and back hits down."
	codex.moveset["RisingSlash"].desc = rising_desc
	#-********************************************************************************************************************\
	#air jab ************************************************************************************************************
	var airjab_desc = "Stab em from the sky! \nit's like a jab, but in the air."
	codex.moveset["Air Jab"].desc = airjab_desc
	#-********************************************************************************************************************
	#joust ************************************************************************************************************
	var joust_desc = "The greatest form of combat! \nPasses through the opponent, and projectiles, on hit and on block"
	codex.moveset["Joust"].desc = joust_desc
	#-********************************************************************************************************************
	#grab ************************************************************************************************************
	var dive_desc = "Descend upon the awaiting audience. \nRapid movement. Carries the opponent to the ground."
	codex.moveset["Esports"].desc = dive_desc
	#-********************************************************************************************************************
	#grab ************************************************************************************************************
	var grab_desc = "Grab your partner and do it as we rehearsed.\n"
	grab_desc += "Grab is weaker on the ground, but sends out a performer. Does average damage in the air\n"
	grab_desc += "Performer throw can be adjusted with DI"
	codex.moveset["Grab"].desc = grab_desc
	#-********************************************************************************************************************
	#Specials
	#command minions ************************************************************************************************************
	var comm_desc = pic(MJOUST) +pic(MDP) +pic(MDIVE) +pic(MPIN) +pic(MDETONATE) +"\n"
	comm_desc += "Command the selected performer to use one of five actions.\n\n"
	comm_desc += "- Far reaching horizontal joust.\n- Chase down the opponent for a rising strike.\n- An aerial dive strike.\n- A fan of weak pin projectiles.\n- Detonate on the spot."
	codex.moveset["minion_attacks"].desc = comm_desc
	#-********************************************************************************************************************
	#skydrop ************************************************************************************************************
	var sky_desc = "All stunts done live! \n\nSend a performer upwards to come down with mild tracking."
	codex.moveset["minion_skydrop"].desc = sky_desc
	#-********************************************************************************************************************
	#summon minion ************************************************************************************************************
	var summon_desc = "Alright you're up! \n\nBring out a backup performer onto the stage."
	codex.moveset["minion_toss"].desc = summon_desc
	#-********************************************************************************************************************
	#needle throw ************************************************************************************************************
	var needle_desc = "The stage is where the impossible comes to life!\n\n"
	needle_desc += "Alonso can pull himself towards the needle in mid flight. If it strikes an opponent or a friendly performer, it will tether to them"
	codex.moveset["NeedleThrow"].desc = needle_desc
	#-********************************************************************************************************************
	#pins and needles ************************************************************************************************************
	var pinsAnd_desc = "A nasty surprise from below stage. \n\nAlways targets ground level."
	codex.moveset["PinSummon"].desc = pinsAnd_desc
	#-********************************************************************************************************************
	#audition ************************************************************************************************************
	var audition_desc = "It's time for a volunteer from the audience!\n\n"
	audition_desc += "A dashing command grab that leaves the opponent tethered. Will only hit either ground or air, based on Alonso's position."
	codex.moveset["ThreadGrabDash"].desc = audition_desc
	#-********************************************************************************************************************
	#conditional
	#zipline ************************************************************************************************************
	var zip_desc = "No distance is too great!\n\n"
	zip_desc += "Is only available immediately after tethering the opponent."
	codex.moveset["ZipStrike"].desc = zip_desc
	#-********************************************************************************************************************
	#center ************************************************************************************************************
	var center_desc = "You need to be standing closer!\n\n"
	center_desc += "Pulls the opponent towards Alonso. Avialable as long as the opponent is tethered."
	codex.moveset["Pull"].desc = center_desc
	#-********************************************************************************************************************
	#punchsplosion ************************************************************************************************************
	var punch_desc = "Show business can be truly unforgiving.\n\n"
	punch_desc += "Sacrifice a performer for a powerful guard break attack. Available as long as a performer is tethered."
	codex.moveset["Ripline"].desc = punch_desc
	#-********************************************************************************************************************
	#Supers
	#party command ************************************************************************************************************
	var teamup_desc = pic(MJOUST) +pic(MDP) +pic(MDIVE) +pic(MPIN) +pic(MDETONATE) +"\n"
	teamup_desc += "[1 Bar] All together now!\n\n"
	teamup_desc += "Command all active performers to perform the same attack pattern.\n\n"
	teamup_desc += "- Far reaching horizontal joust.\n- Chase down the opponent for a rising strike.\n- An aerial dive strike.\n- A fan of weak pin projectiles.\n- Detonate on the spot."
	codex.moveset["minion_attacks2"].desc = teamup_desc
	#-********************************************************************************************************************
	#malfunction command ************************************************************************************************************
	var malfunction_desc = "[2 Bars] That didn't sound right...\n\n"
	malfunction_desc += "A faulty lighting fixture falls upon the target area. And it had some occupants.\n"
	codex.moveset["Lighting_Fixture"].desc = malfunction_desc
	#-********************************************************************************************************************
	
	
	#============ Move Properties ============
	codex.moveset["Grab"].air_type = "Both"
	codex.moveset["JumpClaw"].air_type = "Both"
	
	#============ Move Sorting ============	
	codex.moveset["ZipStrike"].visible = true
	codex.moveset["JumpClawAir"].visible = false
	codex.moveset["NeedleThrowAir"].visible = false
	codex.moveset["AirGrab"].visible = false
	
	codex.stances = ["Normal"]

func _color(color,text):
	var string = "[color=#" + color + "]" + text + "[/color]" 
	return string
	
func pic(picture):
	var string = "[img]" + picture + "[/img]"
	return string

func modify_style_data(style, params):
	var codex_lib = params.codex_library
	var char_path = params.char_path

#func setup_achievements(list):
#	list.default_locked_icon = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLock.png"
#	list.default_unlocked_icon = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach.png"
#	var Normals = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLockNormal.png"
#	var Specials = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLockSpec.png"
#	var Subs = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLockSub.png"
#	var Supers = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLockSuper.png"
#	var Misc = "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchLockMisc.png"
#
#	var Crest = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach1.png"
#	var Bronze = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach25.png"
#	var Silver = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach50.png"
#	var Gold = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach75.png"
#	var Diamond = "res://Belmont_Mod/characters/Belmont/sprites/ASE/Ach100.png"
#
#	#Completion (Hidden) - - -
#	list.set_title("Flameheart_Unlock", "Flameheart")
#	var desc =  _color("7f898f","- selectable from character options\n")
#	desc += "Aqcuired the Flameheart skin. Bringing out the fire whip for extra style"
#	list.set_desc("Flameheart_Unlock", desc)
#	list.set_icon("Flameheart_Unlock", "res://Belmont_Mod/characters/Belmont/sprites/ASE/AchF.png")
#	list.mark_secret("Flameheart_Unlock")
#
#	#Normals - - -
#	list.set_title("Diagonal", "NOW GO DIAGONAL!")
#	list.set_locked_desc("Diagonal", "You can’t do it on the ground...\n[color=#383838]Normals, Progression[/color]" )
#	desc =  _color("7f898f","- Hit the Plasma Flail version of Reverie\n")
#	desc += "The Plasma Flail form of Vampire Killer is probably the most powerful single weapon there is. But it takes intense concentration and a balance between one’s good and evil halves. Which is hard to maintain in an intense fight. The brightest flames surely burn the shortest. Other alchemical weapons can achieve similar forms, though this is most exclusive obviously."
#	list.set_desc("Diagonal", desc)
#	list.set_locked_icon("Diagonal", Normals)
	
#	print(list.get_totals()["visible"])
#	print(list.get_totals()["unlocked_visible"])
#	var unlocks = list.get_totals()["unlocked_visible"]
#	if unlocks >= 1:
#		list.mark_unlocked("Tier0", true)
#	if unlocks >= 6:
#		list.mark_unlocked("Tier1", true)
#	if unlocks >= 18:
#		list.mark_unlocked("Tier2", true)
#	if unlocks >= 21:
#		list.mark_unlocked("Tier3", true)
#	if unlocks >= list.get_totals()["visible"]:
#		list.mark_unlocked("Tier4", true)

