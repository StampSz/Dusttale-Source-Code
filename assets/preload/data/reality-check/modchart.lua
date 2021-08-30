function start (song)
	
end

function update (elapsed)
	if curBeat < 2449 then	
		local currentBeat = (songPos / 1000)*(bpm/150)
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*5.25) * math.pi), i)
	end
end
end

function beatHit (beat)
	
	
end

function stepHit (step)
	
end

function keyPressed (key)
	

end

