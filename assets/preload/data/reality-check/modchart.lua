function start (song)
	
end

function update (elapsed)
	if curStep < 249 then	
		local currentBeat = (songPos / 1000)*(bpm/150)
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*5.25) * math.pi), i)
	end
end
	if curStep > 238 and curStep < 752 then	
		local currentBeat = (songPos / 1000)*(bpm/30)
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*5.25) * math.pi), i)
	end
end
	if curStep > 751 and curStep < 1264 then	
		local currentBeat = (songPos / 1000)*(bpm/150)
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*5.25) * math.pi), i)
	end
end
	if curStep > 1263 and curStep < 1769 then	
		local currentBeat = (songPos / 1000)*(bpm/20)
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*20.25) * math.pi), i)
	end
end
	if curStep > 1835 then	
		local currentBeat = (songPos / 1000)*(bpm/20)
		for i=0,7 do
		setActorY(defaultStrum0Y + 15 * math.cos((currentBeat + i*1.25) * math.pi), i)
	end
end
end

function beatHit (beat)
	
	
end

function stepHit (step)
	
end

function keyPressed (key)
	

end

