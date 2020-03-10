ball = sphere radius:10 wireColor:blue
animate on
( 
	at time 0   ball.pos = [-100,0,0]
	at time 100 ball.pos = [100,0,0]
)

b2 = sphere radius:8 wireColor:red
b3 = sphere radius:4 wireColor:green
animate on for t in 0 to 100 by 5 do
	at time t 
	(
		b2.pos = ball.pos + random [-30,-30,-30] [30,30,30]
		b3.pos = ((ball.pos + b2.pos)/2) 
		ball.radius = 8 + 3 * sin (720 * t / 100)
	)             
