b1 = sphere radius:15 wireColor:green
b1.pos = [-100,-50,16]
animate on
(
	at time 0 (b1.pos = [-100,-50,16]
		rotate b1 (angleaxis 0 [0,1,0]))
	at time 100 (b1.pos = [100,-50,16]
		rotate b1 (angleaxis 360 [0,1,0]))
)

b2 = sphere radius:15 wireColor:yellow
b2.pos = [-100,0,16]
animate on
(
	at time 25 (b2.pos = [-100,0,16]
		rotate b2 (angleaxis 0 [0,1,0]))
	at time 100 (b2.pos = [100,0,16]
		rotate b2 (angleaxis 360 [0,1,0]))
)

b3 = sphere radius:15 wireColor:red
b3.pos = [-100,50,16]
animate on
(
	at time 50 (b3.pos = [-100,50,16]
		rotate b3 (angleaxis 0 [0,1,0]))
	at time 100 (b3.pos = [100,50,16]
		rotate b3 (angleaxis 360 [0,1,0]))
)